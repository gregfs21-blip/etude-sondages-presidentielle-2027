# Méthodologie

Ce document explique précisément ce que calcule le pipeline, chaque choix de
modélisation, et — c'est le plus important — ses limites actuelles. Rien
n'est caché : si un chiffre ici te semble étrange, la réponse est
probablement dans cette page.

## 1. Vue d'ensemble

```
Postgres (sondages bruts)
   │  vue SQL v_poll_bloc_observations (db/views.sql)
   ▼
Node : variance d'observation par sondage (lib/variance.mjs)
   ▼
Node : filtre de Kalman (passe causale) (lib/kalman.mjs)
   ▼
Node : lisseur RTS (passe rétrograde, utilise tout l'historique)
   ▼
Node : projection jusqu'à aujourd'hui (prédiction pure, sans nouvelle donnée)
   ▼
scripts/generate.mjs → dist/index.html (site statique, zéro JS runtime)
```

Postgres est la seule source de vérité. Le HTML généré ne contient aucun
chiffre saisi à la main — tout est recalculé à chaque `npm run generate`.

## 2. Le niveau d'agrégation : "bloc", pas "candidat"

À 8 mois du premier tour, la quasi-totalité des candidatures ne sont pas
déclarées. Les instituts testent plusieurs hypothèses dans une même vague
(ex. "Le Pen" dans un scénario, "Bardella" dans une autre, jamais les deux
ensemble). Traiter "Le Pen" et "Bardella" comme deux candidats distincts
ferait apparaître et disparaître des séries d'un sondage à l'autre sans que
ça reflète un vrai mouvement d'opinion.

Le pipeline regroupe donc les figures par bloc politique (`db/schema.sql`,
table `blocs`) et moyenne, pour un même sondage, les hypothèses qui
concernent le même bloc. C'est un choix assumé, pas neutre : il suppose que
l'électorat RN se reporterait globalement de façon comparable sur Le Pen ou
Bardella, ce qui est plausible mais pas démontré par les données dont on
dispose ici.

**Exception : le bloc « Lisnard » (depuis le 16 novembre 2026).** David
Lisnard est passé de 3-4 % à 10-12 % entre fin septembre et mi-novembre et
dépasse Retailleau dans la plupart des scénarios. Rangé dans « Autres »
(moyenne de petits candidats), ce mouvement était invisible ; additionné à
Retailleau, il aurait créé des sauts artificiels entre scénarios avec et
sans lui. Il est donc suivi dans sa propre série, et le bloc « droite »
devient « LR (Retailleau) ». C'est une série par candidat, qui ne couvre que
les scénarios où il est testé : quand il ne l'est pas, ses électeurs se
répartissent ailleurs. Détail dans `db/insert_20261116_bloc_lisnard.sql`.

## 3. Le modèle statistique

### 3.1 État et observation

Modèle à espace d'état linéaire-gaussien, "marche aléatoire" (local level) :

```
x_t = x_{t-1} + w_t        w_t ~ N(0, Q · Δt)
z_t = x_t + v_t             v_t ~ N(0, R_t)
```

- `x_t` : intention de vote "réelle" du bloc, jamais observée directement.
- `z_t` : le score rapporté par un sondage (moyenne des hypothèses de ce
  sondage pour ce bloc — voir `v_poll_bloc_observations`).
- `Q` : bruit de process PAR JOUR, en points²/jour — plus il est grand, plus
  le modèle autorise l'opinion réelle à bouger vite entre deux sondages.
- `R_t` : variance de l'observation `t` (voir 3.2), différente pour chaque
  sondage selon sa taille d'échantillon et les hypothèses testées.

### 3.2 Variance d'observation (`lib/variance.mjs`)

Deux composantes, additionnées :

**Bruit d'échantillonnage** : `p(1-p)/n`, converti en points² et multiplié
par un *design effect* de 1,5 (valeur courante pour des enquêtes en ligne
par quotas, pas un tirage aléatoire simple — c'est une hypothèse
documentée, pas une mesure). Quand `n` n'est pas publié, une valeur de
repli conservatrice est utilisée (3 pts², ≈ un échantillon de 800 personnes
à 20 %).

**Bruit de scénario** : quand un institut teste plusieurs hypothèses pour
le même bloc dans la même vague, l'écart entre elles n'est PAS de l'erreur
d'échantillonnage — c'est une incertitude réelle sur qui sera candidat.
Modélisée comme la variance d'une loi uniforme sur la fourchette rapportée :
`(high-low)² / 12`.

Un plancher de 0,25 pt² évite qu'une variance nulle (hypothèse unique,
grand échantillon) ne fasse suivre le filtre au chiffre exact du dernier
sondage, comme si aucune autre source d'erreur n'existait.

### 3.3 Filtre de Kalman et lisseur RTS (`lib/kalman.mjs`)

Récursion standard (prédiction puis mise à jour) pour la passe causale ;
lisseur de Rauch-Tung-Striebel pour la passe rétrograde, qui recalcule
chaque point passé à la lumière de TOUTES les observations, y compris
celles venues après. C'est la courbe affichée sur le site — la passe
causale seule ne sert qu'au calcul de vraisemblance (3.4).

### 3.4 Choix de Q — et pourquoi il n'est PAS ajusté aux données ici

`lib/kalman.mjs` implémente `fitProcessVariance()` : un ajustement de `Q`
par maximum de vraisemblance (recherche en grille log-espacée sur la
vraisemblance des innovations), technique standard pour ce type de modèle.

**Mais** avec 2 à 4 sondages bruts par bloc sur trois mois, cet ajustement
n'est pas fiable — trop peu de points pour identifier séparément le bruit
de mesure et le bruit de process. Le pipeline calcule quand même
l'ajustement (affiché sous chaque graphique, à titre de diagnostic), mais
n'utilise le résultat que si :

- il y a au moins 8 sondages bruts pour ce bloc, ET
- l'optimum trouvé n'est pas sur une borne de la grille de recherche
  (signe classique de sous-identification).

Sinon, le pipeline retombe sur une valeur par défaut **documentée, pas
mesurée** : `Q = 0.07 pts²/jour`, choisie pour qu'en l'absence de sondage
pendant ~90 jours, l'écart-type accumulé soit d'environ 2,5 points — un
ordre de grandeur cohérent avec les mouvements observés sur la période
mai-août 2026, mais qui reste un choix arbitraire assumé comme tel. Change
`DEFAULT_PROCESS_VARIANCE_PER_DAY` dans `scripts/generate.mjs` si tu veux
tester une autre hypothèse.

### 3.5 Projection "aujourd'hui"

Le dernier point lissé + une étape de PRÉDICTION pure (`P_pred = P + Q·Δt`,
sans mise à jour puisqu'il n'y a pas de nouvelle observation) jusqu'à la
date de génération. Ce n'est pas une prévision de résultat électoral : c'est
la formalisation honnête du fait qu'on est de moins en moins sûr de l'état
actuel à mesure que le dernier sondage s'éloigne dans le temps.

## 4. Sondages exclus du filtre

`poll_type = 'aggregate_reference'` (ex. la moyenne glissante Elabe/EPOC
Info) n'est jamais lu par `scripts/db.mjs` pour le calcul — seulement pour
le journal affiché. Injecter un agrégat qui recompose déjà plusieurs
sondages bruts individuellement présents en base compterait plusieurs fois
la même information et fausserait à la baisse la variance estimée.

## 5. Limites — à lire avant de faire confiance aux chiffres

1. **N est petit.** 2 à 4 sondages bruts par bloc. Le filtre de Kalman est
   mathématiquement correct, mais avec si peu de points il se comporte
   essentiellement comme une moyenne pondérée par fiabilité — pas comme un
   outil de détection de tendance fine.
2. **Q par défaut n'est pas calibré sur CES données** — voir 3.4. C'est
   l'hypothèse la plus fragile de tout le pipeline.
3. **Les fourchettes RN et Centre encodent une incertitude de candidature,
   pas une marge d'erreur statistique.** Les convertir en variance
   (loi uniforme) est une approximation raisonnable, pas une équivalence
   démontrée.
4. **"House effects" non modélisés.** Un vrai agrégateur (538, The
   Economist) estime aussi un biais systématique propre à chaque institut
   et le corrige. Avec un seul sondage par institut ici, ce n'est pas
   identifiable — non implémenté, pas oublié.
5. **La bande de projection grandit mécaniquement, pas intelligemment.**
   Si aucun sondage n'est ajouté pendant 6 mois, l'intervalle continuera de
   s'élargir jusqu'à devenir peu informatif. C'est le comportement correct
   du modèle, pas un défaut à corriger.

En résumé : ce pipeline fait ce qu'il prétend faire — un lissage
statistiquement défendable d'un petit nombre de sondages — mais ce n'est ni
un modèle de prévision électorale, ni un remplacement pour un agrégateur
professionnel disposant de dizaines de sondages par candidat. Le lire comme
"la tendance la plus probable compte tenu des données disponibles à ce
jour", pas comme "ce qui va se passer".

## 6. Mettre à jour

```bash
psql "$DATABASE_URL" -f db/insert_poll_template.sql   # après l'avoir rempli
npm run generate
```

`dist/index.html` est régénéré en entier. Redéployer sur Vercel (voir
README.md).
