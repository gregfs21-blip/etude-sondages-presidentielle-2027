#!/usr/bin/env node
// Pipeline complet : Postgres -> filtre de Kalman -> site statique.
//
//   1. lit les sondages depuis Postgres (via psql, voir scripts/db.mjs)
//   2. calcule, PAR BLOC, la variance d'observation de chaque sondage brut
//   3. fait tourner le filtre de Kalman + le lisseur RTS sur chaque série
//   4. projette l'estimation jusqu'à aujourd'hui (incertitude qui grandit
//      avec le temps écoulé depuis le dernier sondage, sans "deviner")
//   5. génère dist/index.html — un site statique autonome, sans JS runtime,
//      sans dépendance npm, déployable tel quel sur Vercel.
//
// Ne fait AUCUNE hypothèse implicite : chaque paramètre de modélisation
// (design effect, Q par défaut, seuil de fiabilité MLE) est une constante
// nommée ci-dessous, documentée dans METHODOLOGY.md.

import { writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

import { getBlocs, getAllObservations } from './db.mjs';
import { kalmanFilter, rtsSmoother, fitProcessVariance, daysBetween } from '../lib/kalman.mjs';
import { combinedObservationVariance } from '../lib/variance.mjs';
import { renderBlocChart, renderSynthesisChart } from './chart.mjs';
import { PAGE_CSS } from './styles.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));

// --- constantes de modélisation, documentées dans METHODOLOGY.md ---------
const DEFAULT_PROCESS_VARIANCE_PER_DAY = 0.07; // pts²/jour — voir METHODOLOGY.md
const MIN_N_FOR_RELIABLE_FIT = 8;              // en dessous, le MLE de Q n'est pas fiable
const KALMAN_INITIAL_VARIANCE_MULTIPLIER = 4;

function todayIso() {
  return new Date().toISOString().slice(0, 10);
}

function fmtPct1(n) {
  return n.toLocaleString('fr-FR', { minimumFractionDigits: 1, maximumFractionDigits: 1 });
}

function fmtDateFr(iso) {
  const [y, m, d] = iso.split('-').map(Number);
  const mois = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
  return `${d} ${mois[m - 1]} ${y}`;
}

function computeBlocSeries(bloc, observationsForBloc, asOf) {
  const raw = observationsForBloc
    .filter((o) => o.poll_type === 'raw')
    .sort((a, b) => (a.obs_date < b.obs_date ? -1 : 1));

  if (raw.length === 0) {
    return null;
  }

  const kalmanInput = raw.map((o) => ({
    date: o.obs_date,
    value: o.point_pct_avg,
    variance: combinedObservationVariance({
      pointPct: o.point_pct_avg,
      low: o.low_pct,
      high: o.high_pct,
      n: o.sample_size,
    }),
  }));

  const qDiagnostic = fitProcessVariance(kalmanInput, {
    defaultQ: DEFAULT_PROCESS_VARIANCE_PER_DAY,
    minNForFit: MIN_N_FOR_RELIABLE_FIT,
  });

  const { steps: filtered } = kalmanFilter(kalmanInput, {
    processVariancePerDay: qDiagnostic.usedQ,
    initialVarianceMultiplier: KALMAN_INITIAL_VARIANCE_MULTIPLIER,
  });
  const smoothed = rtsSmoother(filtered, qDiagnostic.usedQ);

  const last = smoothed[smoothed.length - 1];
  const dtToday = Math.max(0, daysBetween(last.date, asOf));
  const projection = {
    date: asOf,
    mean: last.mean,
    variance: last.variance + qDiagnostic.usedQ * dtToday,
  };

  return {
    bloc,
    raw,
    kalmanInput,
    qDiagnostic,
    filtered,
    smoothed,
    projection,
    firstRawDate: raw[0].obs_date,
    firstRawValue: raw[0].point_pct_avg,
  };
}

function buildJournal(allObservations) {
  const byPoll = new Map();
  for (const o of allObservations) {
    if (!byPoll.has(o.poll_id)) {
      byPoll.set(o.poll_id, {
        pollId: o.poll_id,
        pollster: o.pollster_name,
        sponsor: o.sponsor,
        sourceUrl: o.source_url,
        publishedDate: o.published_date,
        pollType: o.poll_type,
        perBloc: {},
      });
    }
    const entry = byPoll.get(o.poll_id);
    const val = o.point_pct === null || o.point_pct === undefined
      ? `${fmtPct1(o.low_pct)}–${fmtPct1(o.high_pct)} %`
      : `${fmtPct1(o.point_pct_avg)} %`;
    entry.perBloc[o.bloc_id] = `${o.candidate_labels} ${o.low_pct === o.high_pct ? fmtPct1(o.low_pct) + ' %' : val}`;
  }
  return [...byPoll.values()].sort((a, b) => (a.publishedDate < b.publishedDate ? 1 : -1));
}

async function main() {
  const asOf = todayIso();
  const blocs = await getBlocs();
  const allObservations = await getAllObservations();

  const byBloc = new Map(blocs.map((b) => [b.id, []]));
  for (const o of allObservations) {
    if (byBloc.has(o.bloc_id)) byBloc.get(o.bloc_id).push(o);
  }

  const series = blocs
    .map((b) => computeBlocSeries(b, byBloc.get(b.id) ?? [], asOf))
    .filter(Boolean);

  const journal = buildJournal(allObservations);

  const sourceUrls = [...new Set(allObservations.map((o) => `${o.pollster_name}|${o.source_url}`))]
    .map((s) => {
      const [name, url] = s.split('|');
      return { name, url };
    });

  const nRawByBloc = series.map((s) => s.raw.length);
  const minN = Math.min(...nRawByBloc);
  const maxN = Math.max(...nRawByBloc);

  const html = renderPage({ asOf, series, journal, sourceUrls, minN, maxN });

  const distDir = join(__dirname, '..', 'dist');
  mkdirSync(distDir, { recursive: true });
  writeFileSync(join(distDir, 'index.html'), html, 'utf8');

  // Dump JSON pour audit / debug — pas servi par le site, juste pour
  // pouvoir vérifier les chiffres calculés sans relire le HTML.
  writeFileSync(
    join(distDir, 'data.json'),
    JSON.stringify(
      series.map((s) => ({
        bloc: s.bloc.id,
        n_raw: s.raw.length,
        q: s.qDiagnostic,
        smoothed: s.smoothed,
        projection: s.projection,
      })),
      null,
      2
    ),
    'utf8'
  );

  console.log(`✓ dist/index.html généré (${series.length} blocs, asOf=${asOf})`);
  series.forEach((s) => {
    console.log(
      `  - ${s.bloc.label.padEnd(22)} n=${s.raw.length}  Q=${s.qDiagnostic.usedQ.toFixed(3)}` +
      `${s.qDiagnostic.reliable ? ' (ajusté)' : ' (défaut)'}` +
      `  proj=${fmtPct1(s.projection.mean)}% ±${fmtPct1(1.96 * Math.sqrt(s.projection.variance))}`
    );
  });
}

function renderPage({ asOf, series, journal, sourceUrls, minN, maxN }) {
  const synthesisHtml = renderSynthesisChart(series, asOf);
  const chartsHtml = series.map((s) => renderBlocChart(
    s.bloc,
    s.raw.map((o) => ({ date: o.obs_date, value: o.point_pct_avg, low: o.low_pct, high: o.high_pct })),
    s.smoothed,
    s.projection,
    s.qDiagnostic
  )).join('\n');

  const estimateRows = series.map((s) => {
    const band = 1.96 * Math.sqrt(s.projection.variance);
    const deltaFirst = s.projection.mean - s.firstRawValue;
    const arrow = Math.abs(deltaFirst) < 0.5 ? '→' : deltaFirst > 0 ? '↑' : '↓';
    const deltaClass = Math.abs(deltaFirst) < 0.5 ? 'flat' : deltaFirst > 0 ? 'up' : 'down';
    return `
      <tr>
        <td><strong>${s.bloc.label}</strong><span class="fig-inline">${s.bloc.description}</span></td>
        <td class="num">${fmtPct1(s.firstRawValue)} % <span class="fig-inline">(${fmtDateFr(s.firstRawDate)})</span></td>
        <td class="num">${fmtPct1(s.projection.mean)} % <span class="fig-inline">± ${fmtPct1(band)}</span></td>
        <td class="num delta ${deltaClass}">${arrow} ${fmtPct1(Math.abs(deltaFirst))} pt</td>
        <td class="num fig">${s.raw.length}</td>
      </tr>`;
  }).join('');

  // La somme des blocs ne fait PAS 100 % — voir Lecture critique #5. On
  // l'affiche explicitement pour que ça ne passe pas pour un oubli ou une
  // erreur de calcul : c'est une conséquence directe de la façon dont le
  // modèle fonctionne (blocs indépendants, sondages non exhaustifs,
  // hypothèses moyennées, pas de catégorie "indécis").
  const sumProjections = series.reduce((acc, s) => acc + s.projection.mean, 0);

  const journalRows = journal.map((j) => {
    const cells = series.map((s) => s.bloc.id)
      .map((bid) => `<td class="fig">${j.perBloc[bid] ?? '—'}</td>`)
      .join('');
    return `
      <tr class="log-row">
        <td>${fmtDateFr(j.publishedDate)}</td>
        <td class="fig">${j.pollster}${j.sponsor ? ' — ' + j.sponsor : ''}${j.pollType === 'aggregate_reference' ? ' <span class="tag">agrégat, exclu du filtre</span>' : ''}</td>
        ${cells}
      </tr>`;
  }).join('');

  const sourcesHtml = sourceUrls.map((s) => `<li><a href="${s.url}">${s.name}</a></li>`).join('\n');

  return `<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Suivi des sondages du premier tour de la présidentielle 2027, lissé par filtre de Kalman à partir d'une base Postgres — généré le ${asOf}.">
<title>Présidentielle 2027 — Suivi (Kalman)</title>
<style>${PAGE_CSS}</style>
</head>
<body>
<div class="wrap">

  <header class="top">
    <div class="eyebrow">Suivi présidentielles — France · pipeline Postgres + Kalman</div>
    <h1>Présidentielle 2027 — les sondages, lissés</h1>
    <p class="subhead">Chaque courbe est calculée par un filtre de Kalman (modèle à marche aléatoire + lisseur RTS) appliqué aux sondages bruts stockés en base. Pas de moyenne à la main : les points sont les sondages, la courbe est le modèle, la bande est son incertitude.</p>
    <div class="meta-row">
      <span><b>Généré le :</b> ${fmtDateFr(asOf)}</span>
      <span><b>1er tour :</b> avril 2027</span>
      <span><b>Sondages bruts par bloc :</b> ${minN === maxN ? minN : `${minN} à ${maxN}`}</span>
    </div>
  </header>

  <section id="contexte">
    <div class="section-label">Contexte</div>
    <h2>Ce qu'il faut savoir avant de lire les chiffres</h2>
    <div class="card">
      <p><b>Le Pen redevient éligible.</b> Condamnée en première instance en mars 2025 à une inéligibilité immédiate de 5 ans, Marine Le Pen a vu sa peine réduite en appel le 7 juillet 2026 à 45 mois d'inéligibilité dont 30 avec sursis — soit 15 mois fermes, rétroactifs à mars 2025 et donc déjà purgés. Elle est de nouveau éligible et a annoncé sa candidature le soir même. Un pourvoi en cassation reste juridiquement possible mais ne l'empêche pas de se présenter.</p>
      <p><b>Conséquence sur le modèle :</b> le bloc RN regroupe les hypothèses "Le Pen" et "Bardella", jamais testées ensemble par un même institut. Le filtre les traite comme des observations bruitées du même bloc — c'est un choix de modélisation assumé (voir METHODOLOGY.md), pas une mesure directe d'un seul candidat.</p>
      <p><b>Quasiment aucune candidature n'est officialisée.</b> Les sondages testent plusieurs configurations par vague ; le pipeline moyenne les hypothèses d'un même sondage pour un même bloc avant de les transmettre au filtre.</p>
    </div>
  </section>

  <section id="estimation">
    <div class="section-label">Estimation du modèle</div>
    <h2>Où en est chaque bloc, au ${fmtDateFr(asOf)}</h2>
    <div class="section-note">Colonne "aujourd'hui" = projection du filtre à la date du jour (dernière estimation lissée + incertitude accumulée depuis le dernier sondage). Intervalle à ~95 %.</div>
    <div class="table-scroll">
      <table>
        <thead>
          <tr>
            <th>Bloc</th>
            <th class="num">1er sondage</th>
            <th class="num">Aujourd'hui (modèle)</th>
            <th class="num">Évolution</th>
            <th class="num">N sondages</th>
          </tr>
        </thead>
        <tbody>${estimateRows}</tbody>
      </table>
    </div>
    <div class="sum-note">Somme des ${series.length} blocs aujourd'hui : <strong>${fmtPct1(sumProjections)} %</strong> — ce n'est pas 100 % et ce n'est pas une erreur de calcul, voir le point 5 de la lecture critique plus bas.</div>
  </section>

  <section id="synthese">
    <div class="section-label">Vue d'ensemble</div>
    <h2>Tous les blocs, une seule courbe par bloc</h2>
    <div class="section-note">Même modèle que ci-dessous (Kalman + lisseur RTS), mais sans les bandes d'incertitude ni les sondages bruts pour rester lisible à ${series.length} courbes superposées — juste la tendance de chaque bloc et sa position relative aux autres. Trait plein = estimation lissée. Pointillé = projection jusqu'à aujourd'hui, sans nouvelle mesure. Détail complet (bandes, points bruts, Q) dans les graphiques par bloc juste après.</div>
    ${synthesisHtml}
  </section>

  <section id="charts">
    <div class="section-label">Séries lissées</div>
    <h2>Filtre de Kalman + lisseur RTS, par bloc</h2>
    <div class="section-note">Points = sondages bruts (le trait fin vertical est la fourchette d'hypothèses telle que rapportée par l'institut, pas une marge d'erreur). Ligne pleine + bande = estimation lissée. Segment pointillé = projection jusqu'à aujourd'hui, sans nouvelle mesure.</div>
    <div class="charts-grid">
      ${chartsHtml}
    </div>
  </section>

  <section id="journal">
    <div class="section-label">Journal des sondages</div>
    <h2>Ce qui est en base — sans la méthodo</h2>
    <div class="section-note">Une ligne par sondage publié. Les lignes marquées "agrégat" sont des moyennes glissantes tierces, gardées pour recoupement mais exclues du filtre (voir METHODOLOGY.md).</div>
    <div class="table-scroll">
      <table>
        <thead>
          <tr><th>Date</th><th>Institut</th>${series.map((s) => `<th>${s.bloc.label}</th>`).join('')}</tr>
        </thead>
        <tbody>${journalRows}</tbody>
      </table>
    </div>
  </section>

  <section id="lecture">
    <div class="section-label">Lecture critique</div>
    <h2>Ce que ce modèle dit vraiment — et ses limites</h2>
    <div class="read-list">
      <div class="read-item"><div class="read-num">1</div>
        <p><b>Le lissage n'est pas de la prévision.</b> Avec ${minN === maxN ? minN : `${minN} à ${maxN}`} sondages bruts par bloc sur trois mois, le filtre se comporte surtout comme une moyenne pondérée par la fiabilité de chaque sondage — utile pour ne pas sur-réagir à un point isolé, pas pour anticiper avril 2027.</p>
      </div>
      <div class="read-item"><div class="read-num">2</div>
        <p><b>Le bruit de process (Q) n'est pas ajusté de façon fiable.</b> Avec moins de ${MIN_N_FOR_RELIABLE_FIT} sondages par bloc, l'estimation de Q par maximum de vraisemblance est instable : le pipeline retombe alors sur une valeur par défaut documentée (${DEFAULT_PROCESS_VARIANCE_PER_DAY} pts²/jour) plutôt que sur un chiffre ajusté aux données — regarde la note "Q=" sous chaque graphique.</p>
      </div>
      <div class="read-item"><div class="read-num">3</div>
        <p><b>Les fourchettes RN et Centre reflètent des hypothèses de candidature, pas une marge d'erreur statistique.</b> Le modèle les convertit en variance additionnelle (loi uniforme sur la fourchette), mais ça reste une incertitude sur QUI sera candidat, pas sur combien il/elle ferait.</p>
      </div>
      <div class="read-item"><div class="read-num">4</div>
        <p><b>La bande de projection grandit mécaniquement avec le temps.</b> Si aucun sondage n'est ajouté pendant plusieurs mois, l'intervalle "aujourd'hui" continuera de s'élargir — c'est le modèle qui dit honnêtement qu'il ne sait plus, pas un bug.</p>
      </div>
      <div class="read-item"><div class="read-num">5</div>
        <p><b>La somme des ${series.length} blocs (${fmtPct1(sumProjections)} % actuellement) ne fait volontairement pas 100 %.</b> Chaque bloc est lissé par son propre filtre de Kalman, sans aucune contrainte qui forcerait le total à 100 % à un instant donné. Trois raisons structurelles à ça : les sondages ne testent pas tous les mêmes candidats, et un bloc dans un même sondage est déjà une moyenne de plusieurs hypothèses (pas un score unique) ; les blocs n'ont pas tous la même date de dernière mesure, donc "aujourd'hui" n'est pas comparé à la même base temporelle partout ; et aucune catégorie "indécis / sans opinion" n'est suivie ici, alors que les sondages à ce stade de la campagne en comptent typiquement 10 à 20 %. Renormaliser pour forcer un total à 100 % serait trompeur — ça ferait comme si ces ${series.length} blocs couvraient tout l'électorat, ce que rien ne démontre. Mieux vaut afficher le vrai total, même imparfait.</p>
      </div>
    </div>
  </section>

  <footer>
    <p>Champ : intentions de vote au 1er tour, France métropolitaine. Pipeline reproductible : schéma et données dans <code>db/</code>, calcul dans <code>lib/kalman.mjs</code> et <code>lib/variance.mjs</code>, généré par <code>npm run generate</code>. Méthodologie complète : voir METHODOLOGY.md dans le dépôt.</p>
    <ul class="sources">
      ${sourcesHtml}
      <li><a href="https://www.euronews.com/my-europe/2026/07/07/french-court-upholds-le-pens-fraud-conviction-threatening-2027-presidential-bid">Euronews — verdict en appel de Marine Le Pen, 7 juillet 2026</a></li>
      <li><a href="https://fr.wikipedia.org/wiki/%C3%89lection_pr%C3%A9sidentielle_fran%C3%A7aise_de_2027">Wikipédia — Élection présidentielle française de 2027 (paysage des candidatures)</a></li>
    </ul>
  </footer>

</div>
</body>
</html>`;
}

main().catch((err) => {
  console.error('✗ Échec de la génération :', err.message);
  process.exit(1);
});
