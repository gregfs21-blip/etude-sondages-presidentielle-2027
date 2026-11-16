// Construit le graphique SVG d'un bloc : nuage des sondages bruts (points +
// segment de fourchette rapportée), courbe lissée RTS avec bande à ~95 %,
// et un segment en pointillé projetant l'estimation jusqu'à "aujourd'hui"
// (date de génération) par simple prédiction sans nouvelle observation —
// ce n'est pas une prévision, juste l'incertitude qui grandit avec le
// temps écoulé depuis le dernier sondage.

const WIDTH = 360;
const HEIGHT = 190;
const MARGIN = { top: 16, right: 14, bottom: 26, left: 30 };

function toTime(iso) {
  return Date.UTC(...iso.split('-').map(Number));
}

function niceMax(value) {
  const step = value > 60 ? 20 : value > 30 ? 10 : 5;
  return Math.ceil((value + step * 0.4) / step) * step;
}

function fmtPct(n) {
  return n.toLocaleString('fr-FR', { minimumFractionDigits: 1, maximumFractionDigits: 1 });
}

function fmtDateShort(iso) {
  const [y, m, d] = iso.split('-').map(Number);
  const mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
  return `${d} ${mois[m - 1]}`;
}

/**
 * @param {object} bloc - {id,label,description,color_hex,color_hex_dark}
 * @param {object[]} rawObs - [{date,value,low,high}]
 * @param {object[]} smoothed - [{date,mean,variance}] (RTS, sur les dates observées)
 * @param {{date:string, mean:number, variance:number}} projection - point à "aujourd'hui"
 * @param {{usedQ:number, reliable:boolean, reasonIfUnreliable:string|null}} qDiagnostic
 */
export function renderBlocChart(bloc, rawObs, smoothed, projection, qDiagnostic) {
  const allDates = [...rawObs.map((o) => o.date), projection.date];
  const minT = toTime(allDates[0]);
  const maxT = toTime(projection.date);
  const span = Math.max(maxT - minT, 1);

  const upperMax = Math.max(
    ...smoothed.map((s) => s.mean + 1.96 * Math.sqrt(s.variance)),
    projection.mean + 1.96 * Math.sqrt(projection.variance),
    ...rawObs.map((o) => o.high)
  );
  const yMax = niceMax(upperMax);

  const x = (iso) => MARGIN.left + ((toTime(iso) - minT) / span) * (WIDTH - MARGIN.left - MARGIN.right);
  const y = (v) => HEIGHT - MARGIN.bottom - (Math.max(v, 0) / yMax) * (HEIGHT - MARGIN.top - MARGIN.bottom);

  // --- grille + axe Y ---------------------------------------------------
  const yTicks = yMax <= 20 ? [0, 5, 10, 15, 20] : yMax <= 40 ? [0, 10, 20, 30, 40] : [0, 20, 40, 60, 80];
  const gridSvg = yTicks.filter((t) => t <= yMax + 0.01).map((t) => `
    <line x1="${MARGIN.left}" x2="${WIDTH - MARGIN.right}" y1="${y(t).toFixed(1)}" y2="${y(t).toFixed(1)}" class="grid-line" />
    <text x="${MARGIN.left - 6}" y="${(y(t) + 3).toFixed(1)}" class="axis-label" text-anchor="end">${t}</text>
  `).join('');

  // --- bande d'incertitude lissée (RTS), en deux tronçons : réel (plein)
  //     puis projeté (pointillé) -----------------------------------------
  const bandPointsReal = [
    ...smoothed.map((s) => [x(s.date), y(s.mean - 1.96 * Math.sqrt(s.variance))]),
    ...[...smoothed].reverse().map((s) => [x(s.date), y(s.mean + 1.96 * Math.sqrt(s.variance))]),
  ];
  const bandReal = smoothed.length >= 2
    ? `<polygon points="${bandPointsReal.map((p) => p.map((n) => n.toFixed(1)).join(',')).join(' ')}" class="band" />`
    : '';

  const lastSmoothed = smoothed[smoothed.length - 1];
  const bandProjPoints = [
    [x(lastSmoothed.date), y(lastSmoothed.mean - 1.96 * Math.sqrt(lastSmoothed.variance))],
    [x(projection.date), y(projection.mean - 1.96 * Math.sqrt(projection.variance))],
    [x(projection.date), y(projection.mean + 1.96 * Math.sqrt(projection.variance))],
    [x(lastSmoothed.date), y(lastSmoothed.mean + 1.96 * Math.sqrt(lastSmoothed.variance))],
  ];
  const bandProj = `<polygon points="${bandProjPoints.map((p) => p.map((n) => n.toFixed(1)).join(',')).join(' ')}" class="band band-proj" />`;

  // --- ligne lissée -------------------------------------------------------
  const linePts = smoothed.map((s) => `${x(s.date).toFixed(1)},${y(s.mean).toFixed(1)}`).join(' ');
  const lineReal = `<polyline points="${linePts}" class="mean-line" />`;
  const lineProj = `<line x1="${x(lastSmoothed.date).toFixed(1)}" y1="${y(lastSmoothed.mean).toFixed(1)}" x2="${x(projection.date).toFixed(1)}" y2="${y(projection.mean).toFixed(1)}" class="mean-line mean-line-proj" />`;

  // --- points bruts + fourchette rapportée --------------------------------
  const dots = rawObs.map((o) => `
    <line x1="${x(o.date).toFixed(1)}" x2="${x(o.date).toFixed(1)}" y1="${y(o.low).toFixed(1)}" y2="${y(o.high).toFixed(1)}" class="raw-range" />
    <circle cx="${x(o.date).toFixed(1)}" cy="${y(o.value).toFixed(1)}" r="3.4" class="raw-dot" />
  `).join('');

  const projDot = `<circle cx="${x(projection.date).toFixed(1)}" cy="${y(projection.mean).toFixed(1)}" r="3.4" class="proj-dot" />`;

  const lastLabel = `${fmtPct(projection.mean)} % ±${fmtPct(1.96 * Math.sqrt(projection.variance))}`;
  const labelX = Math.min(x(projection.date), WIDTH - MARGIN.right - 4);
  const labelY = Math.max(y(projection.mean) - 8, MARGIN.top + 8);

  return `
  <figure class="bloc-chart" style="--light:${bloc.color_hex};--dark:${bloc.color_hex_dark}">
    <figcaption>
      <strong>${bloc.label}</strong>
      <span class="fig">${bloc.description}</span>
    </figcaption>
    <svg viewBox="0 0 ${WIDTH} ${HEIGHT}" role="img" aria-label="Estimation lissée du bloc ${bloc.label}, ${fmtPct(projection.mean)} pourcent au ${fmtDateShort(projection.date)}">
      ${gridSvg}
      ${bandProj}
      ${bandReal}
      ${lineProj}
      ${lineReal}
      ${dots}
      ${projDot}
      <text x="${labelX.toFixed(1)}" y="${labelY.toFixed(1)}" class="point-label" text-anchor="end">${lastLabel}</text>
      <text x="${MARGIN.left}" y="${HEIGHT - 6}" class="axis-label" text-anchor="start">${fmtDateShort(allDates[0])}</text>
      <text x="${WIDTH - MARGIN.right}" y="${HEIGHT - 6}" class="axis-label" text-anchor="end">${fmtDateShort(projection.date)} (proj.)</text>
    </svg>
    <div class="q-note">
      Q = ${qDiagnostic.usedQ.toFixed(3)} pts²/j
      ${qDiagnostic.reliable ? '(ajusté par vraisemblance)' : `(valeur par défaut — ${qDiagnostic.reasonIfUnreliable})`}
    </div>
  </figure>`;
}

// -----------------------------------------------------------------------
// Graphe de synthèse : toutes les courbes lissées superposées sur un seul
// graphique, pour comparer les blocs entre eux d'un coup d'œil. Volontai-
// rement dépouillé par rapport aux petits multiples ci-dessous : pas de
// bandes d'incertitude (6 bandes translucides superposées deviendraient
// illisibles), pas de points bruts — juste les courbes lissées RTS
// (traits pleins) + leur projection jusqu'à aujourd'hui (pointillés), avec
// une étiquette directe au bout de chaque ligne plutôt qu'une légende à
// part (plus rapide à lire que d'aller-retourner entre couleurs et clé).
// Le détail (bandes, sondages bruts, diagnostic Q) reste dans les petits
// multiples juste en dessous : ce graphe est un résumé, pas un remplacement.

const SYN_WIDTH = 940;
const SYN_HEIGHT = 380;
// right assez large pour "Gauche mod. / écolo · 10,7 %" (le plus long label
// bloc+valeur) sans être coupé par le bord du viewBox, à 11px monospace.
const SYN_MARGIN = { top: 20, right: 252, bottom: 32, left: 36 };
const SYN_MIN_LABEL_GAP = 15; // px, évite que deux étiquettes proches se chevauchent

/**
 * @param {{bloc:object, smoothed:object[], projection:object}[]} seriesList - un élément par bloc, dans l'ordre d'affichage voulu
 * @param {string} asOf - date ISO de génération (bout droit du graphe)
 */
export function renderSynthesisChart(seriesList, asOf) {
  const allDates = seriesList.flatMap((s) => s.smoothed.map((p) => p.date));
  const minT = Math.min(...allDates.map(toTime));
  const maxT = toTime(asOf);
  const span = Math.max(maxT - minT, 1);

  const upperMax = Math.max(
    ...seriesList.flatMap((s) => [...s.smoothed.map((p) => p.mean), s.projection.mean])
  );
  const yMax = niceMax(upperMax + 2);

  const x = (iso) => SYN_MARGIN.left + ((toTime(iso) - minT) / span) * (SYN_WIDTH - SYN_MARGIN.left - SYN_MARGIN.right);
  const y = (v) => SYN_HEIGHT - SYN_MARGIN.bottom - (Math.max(v, 0) / yMax) * (SYN_HEIGHT - SYN_MARGIN.top - SYN_MARGIN.bottom);

  const yTicks = yMax <= 20 ? [0, 5, 10, 15, 20] : yMax <= 40 ? [0, 10, 20, 30, 40] : [0, 20, 40, 60, 80];
  const gridSvg = yTicks.filter((t) => t <= yMax + 0.01).map((t) => `
    <line x1="${SYN_MARGIN.left}" x2="${SYN_WIDTH - SYN_MARGIN.right}" y1="${y(t).toFixed(1)}" y2="${y(t).toFixed(1)}" class="grid-line" />
    <text x="${SYN_MARGIN.left - 8}" y="${(y(t) + 4).toFixed(1)}" class="axis-label-lg" text-anchor="end">${t}</text>
  `).join('');

  const seriesEntries = seriesList.map((s) => {
    const linePtsReal = s.smoothed.map((p) => `${x(p.date).toFixed(1)},${y(p.mean).toFixed(1)}`).join(' ');
    const last = s.smoothed[s.smoothed.length - 1];
    const lineMarkup = `
    <g class="synth-series" style="--light:${s.bloc.color_hex};--dark:${s.bloc.color_hex_dark}">
      <polyline points="${linePtsReal}" class="synth-line" />
      <line x1="${x(last.date).toFixed(1)}" y1="${y(last.mean).toFixed(1)}" x2="${x(s.projection.date).toFixed(1)}" y2="${y(s.projection.mean).toFixed(1)}" class="synth-line synth-line-proj" />
      <circle cx="${x(s.projection.date).toFixed(1)}" cy="${y(s.projection.mean).toFixed(1)}" r="3.4" class="synth-dot" />
    </g>`;
    return { bloc: s.bloc, value: s.projection.mean, dotY: y(s.projection.mean), lineMarkup };
  });

  // Étiquettes directes en bout de ligne, avec anti-collision verticale
  // simple (tri par valeur, écart minimal imposé de haut en bas).
  const labelsSorted = [...seriesEntries].sort((a, b) => a.dotY - b.dotY);
  labelsSorted.forEach((entry, i) => {
    entry.labelY = i === 0 ? entry.dotY : Math.max(entry.dotY, labelsSorted[i - 1].labelY + SYN_MIN_LABEL_GAP);
  });
  const maxAllowedY = SYN_HEIGHT - SYN_MARGIN.bottom;
  const overflow = labelsSorted.length ? labelsSorted[labelsSorted.length - 1].labelY - maxAllowedY : 0;
  if (overflow > 0) labelsSorted.forEach((entry) => { entry.labelY -= overflow; });

  const labelsSvg = labelsSorted.map((entry) => {
    const needsLeader = Math.abs(entry.labelY - entry.dotY) > 2.5;
    const leader = needsLeader
      ? `<line x1="${(SYN_WIDTH - SYN_MARGIN.right + 4).toFixed(1)}" x2="${(SYN_WIDTH - SYN_MARGIN.right + 12).toFixed(1)}" y1="${entry.dotY.toFixed(1)}" y2="${entry.labelY.toFixed(1)}" class="synth-leader" />`
      : '';
    return `
    <g class="synth-series" style="--light:${entry.bloc.color_hex};--dark:${entry.bloc.color_hex_dark}">
      ${leader}
      <text x="${(SYN_WIDTH - SYN_MARGIN.right + 16).toFixed(1)}" y="${(entry.labelY + 3.6).toFixed(1)}" class="synth-label">${entry.bloc.label} · ${fmtPct(entry.value)} %</text>
    </g>`;
  }).join('');

  const linesSvg = seriesEntries.map((e) => e.lineMarkup).join('');

  return `
  <div class="synthesis-card">
    <svg viewBox="0 0 ${SYN_WIDTH} ${SYN_HEIGHT}" role="img" aria-label="Vue de synthèse : toutes les courbes lissées par bloc, au ${fmtDateShort(asOf)}">
      ${gridSvg}
      ${linesSvg}
      ${labelsSvg}
      <text x="${SYN_MARGIN.left}" y="${SYN_HEIGHT - 8}" class="axis-label-lg" text-anchor="start">${fmtDateShort(allDates.sort()[0])}</text>
      <text x="${(SYN_WIDTH - SYN_MARGIN.right).toFixed(1)}" y="${SYN_HEIGHT - 8}" class="axis-label-lg" text-anchor="end">${fmtDateShort(asOf)} (proj.)</text>
    </svg>
  </div>`;
}
