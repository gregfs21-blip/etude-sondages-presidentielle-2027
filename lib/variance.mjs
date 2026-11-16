// Estimation de la variance d'observation associée à un sondage.
//
// Deux sources de bruit bien distinctes sont combinées, et il est important
// de ne pas les confondre :
//
//  1. Le bruit d'échantillonnage classique (aléa de sondage à taille
//     d'échantillon donnée) : var = p(1-p)/n, multipliée par un "effet de
//     plan" (design effect) car les sondages en ligne par quotas ne sont
//     pas des tirages aléatoires simples — 1,5 est une valeur courante en
//     pratique pour ce type d'enquête, documentée ici comme hypothèse, pas
//     comme fait mesuré.
//
//  2. Le bruit "de scénario" : quand un institut teste plusieurs
//     hypothèses de candidature pour le même bloc dans la même vague
//     (Le Pen OU Bardella), l'écart entre ces hypothèses n'est PAS de
//     l'erreur d'échantillonnage — c'est une incertitude réelle sur qui
//     sera candidat. On la modélise comme la variance d'une loi uniforme
//     sur la fourchette [low, high] rapportée : var = (high-low)² / 12.
//
// Les deux variances s'additionnent (indépendance supposée).

export const DEFAULT_DESIGN_EFFECT = 1.5;

// Valeur de repli quand la taille d'échantillon n'est pas publiée :
// équivalent à un institut de ~800 répondants sur un score proche de 20 %,
// hypothèse volontairement conservatrice (plutôt trop prudente que trop
// confiante) documentée ici, pas mesurée.
export const DEFAULT_SAMPLING_VARIANCE_PCT2 = 3.0;

/**
 * Variance d'échantillonnage, en points de pourcentage au carré.
 * @param {number} pointPct - estimation ponctuelle en % (0-100)
 * @param {number|null} n - taille d'échantillon, ou null si inconnue
 * @param {number} designEffect
 * @returns {number}
 */
export function samplingVariancePct(pointPct, n, designEffect = DEFAULT_DESIGN_EFFECT) {
  if (!n || n <= 0) return DEFAULT_SAMPLING_VARIANCE_PCT2;
  const p = pointPct / 100;
  const varProportion = (p * (1 - p)) / n;
  return varProportion * 10000 * designEffect;
}

/**
 * Variance "de scénario" issue de l'écart entre hypothèses testées.
 * @param {number} low
 * @param {number} high
 * @returns {number}
 */
export function scenarioSpreadVariance(low, high) {
  const width = high - low;
  if (width <= 0) return 0;
  return (width * width) / 12;
}

/**
 * Variance d'observation combinée pour une ligne de v_poll_bloc_observations.
 * @param {{pointPct:number, low:number, high:number, n:number|null, designEffect?:number}} o
 * @returns {number}
 */
export function combinedObservationVariance(o) {
  const sampling = samplingVariancePct(o.pointPct, o.n, o.designEffect);
  const spread = scenarioSpreadVariance(o.low, o.high);
  // plancher pour éviter une variance nulle (n grand + hypothèse unique)
  // qui donnerait un gain de Kalman de 1 et ferait suivre le bruit à la lettre
  const FLOOR_PCT2 = 0.25; // std ≈ 0,5 pt
  return Math.max(sampling + spread, FLOOR_PCT2);
}
