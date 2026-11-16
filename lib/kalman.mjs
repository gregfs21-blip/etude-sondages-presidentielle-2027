// Filtre de Kalman scalaire (modèle "local level" / marche aléatoire) +
// lisseur de Rauch-Tung-Striebel (RTS), pour estimer l'intention de vote
// "réelle" d'un bloc à partir d'observations de sondages bruitées et
// irrégulièrement espacées dans le temps.
//
// Modèle d'état :
//   x_t = x_{t-1} + w_t,   w_t ~ N(0, Q · dt)      (marche aléatoire, pas de dérive)
//   z_t = x_t + v_t,       v_t ~ N(0, R_t)          (observation = sondage)
//
// Q est le bruit de process PAR JOUR (points² / jour) : plus Q est grand,
// plus on autorise l'opinion "vraie" à bouger vite entre deux sondages, et
// moins le filtre lisse les à-coups. R_t est la variance d'observation du
// sondage t (voir lib/variance.mjs), qui varie d'un sondage à l'autre.
//
// Aucune dépendance externe : implémentation directe des équations
// standard du filtre de Kalman scalaire et du lisseur RTS.

/**
 * @typedef {{date: string, value: number, variance: number}} Observation
 * @typedef {{date: string, mean: number, variance: number, predMean: number, predVariance: number, kalmanGain?: number}} FilterStep
 */

export function daysBetween(isoA, isoB) {
  const a = Date.UTC(...isoA.split('-').map(Number));
  const b = Date.UTC(...isoB.split('-').map(Number));
  return (b - a) / 86400000;
}

/**
 * Passe forward (causale) : à l'instant t, n'utilise que les observations
 * <= t. C'est ce qu'on aurait pu dire "en direct" à chaque nouveau sondage.
 * @param {Observation[]} observations - triées par date croissante
 * @param {{processVariancePerDay: number, initialVarianceMultiplier?: number}} opts
 * @returns {{steps: FilterStep[], logLikelihood: number}}
 */
export function kalmanFilter(observations, opts) {
  const Q = opts.processVariancePerDay;
  const initMult = opts.initialVarianceMultiplier ?? 4;
  if (!Number.isFinite(Q) || Q < 0) {
    throw new Error(`processVariancePerDay invalide: ${Q}`);
  }
  if (observations.length === 0) return { steps: [], logLikelihood: 0 };

  const steps = [];
  let x, P;
  let logLikelihood = 0;

  observations.forEach((o, i) => {
    if (i === 0) {
      // Premier point : pas de prédiction possible, on part de
      // l'observation elle-même avec une incertitude gonflée (on ne sait
      // pas encore si c'est un point "normal" ou un accident de mesure).
      x = o.value;
      P = o.variance * initMult;
      steps.push({ date: o.date, mean: x, variance: P, predMean: x, predVariance: P });
      return;
    }
    const dt = Math.max(0, daysBetween(observations[i - 1].date, o.date));
    const predMean = x;
    const predVariance = P + Q * dt;

    const innovation = o.value - predMean;
    const innovationVariance = predVariance + o.variance;
    // log-vraisemblance gaussienne de l'innovation — sert à lib/fit.mjs
    logLikelihood += -0.5 * Math.log(2 * Math.PI * innovationVariance)
      - 0.5 * (innovation * innovation) / innovationVariance;

    const K = predVariance / innovationVariance;
    x = predMean + K * innovation;
    P = (1 - K) * predVariance;

    steps.push({ date: o.date, mean: x, variance: P, predMean, predVariance, kalmanGain: K });
  });

  return { steps, logLikelihood };
}

/**
 * Lisseur RTS : passe backward qui recalcule, pour CHAQUE instant passé,
 * la meilleure estimation compte tenu de TOUTES les observations (y
 * compris celles venues après). C'est la courbe à afficher pour lire
 * l'historique — la version causale (kalmanFilter seul) sert surtout à
 * calculer la vraisemblance et à documenter ce qu'on aurait su "en direct".
 * @param {FilterStep[]} filteredSteps - sortie de kalmanFilter(...).steps
 * @param {number} processVariancePerDay
 * @returns {{date:string, mean:number, variance:number}[]}
 */
export function rtsSmoother(filteredSteps, processVariancePerDay) {
  const Q = processVariancePerDay;
  const n = filteredSteps.length;
  if (n === 0) return [];
  const smoothed = new Array(n);
  smoothed[n - 1] = {
    date: filteredSteps[n - 1].date,
    mean: filteredSteps[n - 1].mean,
    variance: filteredSteps[n - 1].variance,
  };
  for (let t = n - 2; t >= 0; t--) {
    const dt = Math.max(0, daysBetween(filteredSteps[t].date, filteredSteps[t + 1].date));
    const predVarianceNext = filteredSteps[t].variance + Q * dt; // P_{t+1|t}
    const predMeanNext = filteredSteps[t].mean;                  // x_{t+1|t}
    const C = predVarianceNext > 0 ? filteredSteps[t].variance / predVarianceNext : 0;
    const mean = filteredSteps[t].mean + C * (smoothed[t + 1].mean - predMeanNext);
    const variance = filteredSteps[t].variance
      + C * C * (smoothed[t + 1].variance - predVarianceNext);
    smoothed[t] = { date: filteredSteps[t].date, mean, variance: Math.max(variance, 0) };
  }
  return smoothed;
}

/**
 * Ajuste Q par maximum de vraisemblance (recherche en grille log-espacée) —
 * technique standard pour un modèle d'état linéaire-gaussien. AVERTIT
 * explicitement (`reliable: false`) quand l'échantillon est trop petit ou
 * que l'optimum tombe sur une borne de la grille : avec 3-5 sondages, cet
 * ajustement n'est pas fiable et ne doit pas remplacer un Q documenté par
 * défaut. Voir METHODOLOGY.md.
 * @param {Observation[]} observations
 * @param {{qMin?:number, qMax?:number, steps?:number, minNForFit?:number, defaultQ:number}} opts
 */
export function fitProcessVariance(observations, opts) {
  const qMin = opts.qMin ?? 0.001;
  const qMax = opts.qMax ?? 2.0;
  const gridSteps = opts.steps ?? 60;
  const minN = opts.minNForFit ?? 8;
  const defaultQ = opts.defaultQ;

  let bestQ = null;
  let bestLL = -Infinity;
  const logMin = Math.log(qMin);
  const logMax = Math.log(qMax);
  for (let i = 0; i <= gridSteps; i++) {
    const q = Math.exp(logMin + ((logMax - logMin) * i) / gridSteps);
    const { logLikelihood } = kalmanFilter(observations, { processVariancePerDay: q });
    if (logLikelihood > bestLL) {
      bestLL = logLikelihood;
      bestQ = q;
    }
  }

  const atBound = bestQ !== null && (bestQ <= qMin * 1.05 || bestQ >= qMax * 0.95);
  const enoughData = observations.length >= minN;
  const reliable = enoughData && !atBound;

  return {
    fittedQ: bestQ,
    fittedLogLikelihood: bestLL,
    reliable,
    reasonIfUnreliable: !enoughData
      ? `seulement ${observations.length} observation(s), < ${minN} requis pour un ajustement stable`
      : atBound ? 'optimum sur une borne de la grille de recherche (signe de sous-identification)'
      : null,
    usedQ: reliable ? bestQ : defaultQ,
  };
}
