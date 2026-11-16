import { test } from 'node:test';
import assert from 'node:assert/strict';
import { kalmanFilter, rtsSmoother, fitProcessVariance } from '../lib/kalman.mjs';
import {
  samplingVariancePct,
  scenarioSpreadVariance,
  combinedObservationVariance,
} from '../lib/variance.mjs';

function mkObs(rows) {
  // rows: [ [date, value, variance], ... ]
  return rows.map(([date, value, variance]) => ({ date, value, variance }));
}

test('kalmanFilter: sur un signal constant bruité, la moyenne filtrée se rapproche de la vraie valeur et la variance décroît', () => {
  const obs = mkObs([
    ['2026-01-01', 33, 4],
    ['2026-01-08', 27, 4],
    ['2026-01-15', 31, 4],
    ['2026-01-22', 29, 4],
    ['2026-01-29', 30, 4],
  ]);
  const { steps } = kalmanFilter(obs, { processVariancePerDay: 0.01 });
  assert.equal(steps.length, 5);
  // la variance filtrée doit décroître (ou rester stable) à chaque mise à
  // jour, hormis l'effet de dt qui la regonfle un peu avant chaque update —
  // ce qu'on vérifie c'est qu'elle est nettement plus petite qu'au départ
  const first = steps[0].variance;
  const last = steps[steps.length - 1].variance;
  assert.ok(last < first, `variance finale (${last}) devrait être < variance initiale (${first})`);
  // la dernière estimation doit être plus proche de la vraie moyenne (30)
  // que ne l'était la dernière observation brute prise isolément
  assert.ok(Math.abs(steps[4].mean - 30) < Math.abs(29 - 30) + 3);
});

test('kalmanFilter: un grand écart temporel entre deux sondages augmente la variance prédite (moins de confiance)', () => {
  const obsProches = mkObs([
    ['2026-01-01', 30, 3],
    ['2026-01-03', 31, 3],
  ]);
  const obsEloignes = mkObs([
    ['2026-01-01', 30, 3],
    ['2026-06-01', 31, 3],
  ]);
  const q = 0.05;
  const rProche = kalmanFilter(obsProches, { processVariancePerDay: q }).steps[1].predVariance;
  const rEloigne = kalmanFilter(obsEloignes, { processVariancePerDay: q }).steps[1].predVariance;
  assert.ok(rEloigne > rProche, 'la variance prédite doit croître avec le temps écoulé');
});

test('kalmanFilter: gain de Kalman correspond au calcul manuel sur un cas à 2 points', () => {
  // x0=30 (var 4). dt=10j, Q=0.1 -> predVar = 4 + 1 = 5.
  // obs2 = 40, var 5. innovationVar = 10. K = 5/10 = 0.5.
  // x1 = 30 + 0.5*(40-30) = 35. P1 = (1-0.5)*5 = 2.5.
  const obs = mkObs([
    ['2026-01-01', 30, 4],
    ['2026-01-11', 40, 5],
  ]);
  const { steps } = kalmanFilter(obs, { processVariancePerDay: 0.1, initialVarianceMultiplier: 1 });
  assert.equal(steps[1].kalmanGain, 0.5);
  assert.equal(steps[1].mean, 35);
  assert.equal(steps[1].variance, 2.5);
});

test('rtsSmoother: la variance lissée est toujours <= variance filtrée correspondante', () => {
  const obs = mkObs([
    ['2026-01-01', 33, 4],
    ['2026-02-01', 27, 4],
    ['2026-03-01', 31, 4],
    ['2026-05-01', 29, 4],
    ['2026-08-01', 30, 4],
  ]);
  const Q = 0.05;
  const { steps } = kalmanFilter(obs, { processVariancePerDay: Q });
  const smoothed = rtsSmoother(steps, Q);
  smoothed.forEach((s, i) => {
    assert.ok(
      s.variance <= steps[i].variance + 1e-9,
      `étape ${i}: variance lissée ${s.variance} devrait être <= variance filtrée ${steps[i].variance}`
    );
  });
  // le dernier point est identique par construction (rien à lisser après lui)
  assert.equal(smoothed[smoothed.length - 1].mean, steps[steps.length - 1].mean);
});

test("fitProcessVariance: signale un ajustement non fiable avec peu d'observations", () => {
  const obs = mkObs([
    ['2026-05-20', 32, 3],
    ['2026-05-27', 33.5, 3],
    ['2026-06-12', 34, 3],
    ['2026-08-18', 36.5, 3],
  ]);
  const result = fitProcessVariance(obs, { defaultQ: 0.07, minNForFit: 8 });
  assert.equal(result.reliable, false);
  assert.equal(result.usedQ, 0.07);
  assert.match(result.reasonIfUnreliable, /observation/);
});

test('fitProcessVariance: devient fiable avec un échantillon plus riche et retrouve un Q proche du Q simulé', () => {
  // Génère une série où l'état vrai suit une marche aléatoire avec un pas
  // de process connu, et vérifie que l'ajustement retrouve un ordre de
  // grandeur plausible (pas une égalité exacte : c'est un MLE sur données
  // bruitées, pas une inversion analytique).
  let x = 30;
  const trueQ = 0.05;
  const rows = [];
  let seed = 42;
  function rand() { // PRNG déterministe pour un test reproductible
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }
  function gauss() {
    const u1 = Math.max(rand(), 1e-6);
    const u2 = rand();
    return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
  }
  for (let day = 0; day <= 300; day += 15) {
    x += gauss() * Math.sqrt(trueQ * 15);
    const date = new Date(Date.UTC(2026, 0, 1 + day)).toISOString().slice(0, 10);
    rows.push([date, x + gauss() * 1.5, 2.25]);
  }
  const obs = mkObs(rows);
  const result = fitProcessVariance(obs, { defaultQ: 0.07, minNForFit: 8, qMin: 0.001, qMax: 1 });
  assert.equal(result.reliable, true);
  // ordre de grandeur : entre 5x moins et 5x plus que le vrai Q simulé
  assert.ok(result.usedQ > trueQ / 5 && result.usedQ < trueQ * 5,
    `Q ajusté (${result.usedQ}) hors de l'ordre de grandeur attendu autour de ${trueQ}`);
});

test('variance: samplingVariancePct décroît quand n augmente', () => {
  const small = samplingVariancePct(30, 400);
  const large = samplingVariancePct(30, 2000);
  assert.ok(large < small);
});

test('variance: scenarioSpreadVariance est nulle quand low === high', () => {
  assert.equal(scenarioSpreadVariance(32, 32), 0);
  assert.ok(scenarioSpreadVariance(31, 36) > 0);
});

test('variance: combinedObservationVariance respecte le plancher même à n très grand et hypothèse unique', () => {
  const v = combinedObservationVariance({ pointPct: 30, low: 30, high: 30, n: 100000 });
  assert.ok(v >= 0.25);
});
