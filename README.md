# Présidentielle 2027 — Suivi (Postgres + filtre de Kalman)

Pipeline complet : Postgres stocke les sondages bruts, un filtre de Kalman
(+ lisseur RTS) les lisse par bloc politique, et un script Node génère un
site statique autonome (`dist/index.html`) déployable tel quel sur Vercel.
Une seule dépendance npm (`pg`, le driver Postgres standard) — voir
"Dépendances" plus bas pour pourquoi la toute première version qui s'en
passait cassait sur Vercel.

Voir **METHODOLOGY.md** pour ce que le modèle calcule exactement et ses
limites — à lire avant de faire confiance aux chiffres.

## Dépendances

Une seule : [`pg`](https://node-postgres.com), le driver Postgres standard
pour Node. Pas de framework web — le HTML/SVG est généré directement en JS.

**Historique** : la toute première version de ce script parlait à Postgres
en shellant vers le binaire `psql`, pour éviter toute dépendance npm.
Ça fonctionnait en local, mais **cassait le déploiement sur Vercel** :
l'image de build de Vercel n'embarque pas `psql` (ce n'est pas un
environnement Postgres, juste Node), donc `npm run generate` y échouait
avec `psql: command not found`, quel que soit le réglage de
`DATABASE_URL`. `pg` s'installe normalement dans n'importe quel
environnement Node standard, Vercel inclus — c'est la version actuelle du
script, pas une option.

`npm test` (voir plus bas) ne touche pas à Postgres et n'a besoin d'aucune
installation. `npm run generate` a besoin de `npm install` au préalable.

## 1. Provisionner Postgres

N'importe quel Postgres fonctionne. Le plus simple avec Vercel : dans le
dashboard du projet Vercel → onglet **Storage** → **Create Database** →
Postgres (Neon). Ça donne directement une variable `DATABASE_URL`.

Sans Vercel : [Neon](https://neon.tech), [Supabase](https://supabase.com),
ou un Postgres classique — il faut juste une URL de connexion au format
`postgresql://user:password@host:port/dbname`.

## 2. Charger le schéma et les données

```bash
export DATABASE_URL="postgresql://..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f db/schema.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f db/views.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f db/seed.sql
```

`db/schema.sql` est idempotent (DROP ... IF EXISTS) : tu peux le rejouer
sans risque en dev.

## 3. Tester le calcul (sans toucher à la base)

```bash
npm test
```

9 tests sur `lib/kalman.mjs` et `lib/variance.mjs` : convergence sur signal
bruité, croissance de la variance avec l'écart temporel, cohérence du
lisseur RTS, cas analytique vérifié à la main, et récupération d'un ordre
de grandeur correct de Q sur données simulées. Aucun besoin de Postgres
pour cette étape — c'est du JS pur.

## 4. Générer le site

```bash
npm install               # récupère `pg` — une seule fois
export DATABASE_URL="postgresql://..."
npm run generate
```

Produit `dist/index.html` (le site) et `dist/data.json` (dump des séries
calculées, pratique pour vérifier un chiffre sans relire le HTML). La
commande affiche aussi, pour chaque bloc, le nombre de sondages utilisés et
le `Q` retenu — vérifie que ça correspond à ce que tu attends avant de
déployer.

## 5. Déployer sur Vercel (Git, depuis le 16 novembre 2026)

Le dépôt GitHub `gregfs21-blip/etude-sondages-presidentielle-2027` est
connecté à Vercel : **chaque push sur `main` redéploie la production.**

Il n'y a pas de Postgres hébergé : la base est reconstruite à la demande à
partir des fichiers `db/*.sql` (qui sont la source de vérité). Le site est
donc généré en local, et `dist/` est **commité** (il n'est plus dans
`.gitignore`). Côté Vercel, `vercel.json` ne lance aucune installation et
le build se limite à `scripts/check-dist.mjs`, qui fait échouer le
déploiement si `dist/index.html` est absent ou tronqué.

Cycle de mise à jour :

```bash
# 1. ajouter le nouveau fichier db/insert_AAAAMMJJ_*.sql
# 2. recharger une base locale (schema, views, seed, puis db/insert_2026*.sql
#    par ordre alphabétique) et exporter DATABASE_URL
npm test
npm run generate          # régénère dist/index.html et dist/data.json
git add db dist && git commit -m "Sondages du JJ/MM" && git push
```

Le site est du HTML statique pur (plus de page « chargeur » ni de découpage
en morceaux, qui n'étaient qu'un contournement de l'envoi fichier par
fichier via l'API).

Si un jour une base hébergée est ajoutée (variable `DATABASE_URL` dans le
projet Vercel), on pourra revenir à `buildCommand: npm run generate` et
retirer `dist/` du dépôt.

## 6. Ajouter un nouveau sondage

```bash
cp db/insert_poll_template.sql db/insert_$(date +%Y%m%d).sql
# éditer le fichier copié avec les vraies valeurs
psql "$DATABASE_URL" -f db/insert_$(date +%Y%m%d).sql
npm run generate
```

Puis redéployer (option A ou B ci-dessus).

## Dépannage

Si `npm run generate` (en local ou pendant le build Vercel) échoue :

- **`Cannot find module 'pg'`** → `npm install` n'a pas tourné. En local :
  lance-le à la main. Sur Vercel : vérifie qu'aucun "Install Command"
  personnalisé n'a été mis dans les réglages du projet (le défaut `npm
  install` doit rester actif).
- **`DATABASE_URL n'est pas défini`** → la variable d'environnement manque.
  Sur Vercel, elle se règle par environnement (Production / Preview /
  Development séparément) dans Project Settings → Environment Variables —
  vérifie qu'elle est cochée pour l'environnement que tu déploies.
- **Erreur de connexion / certificat TLS** → vérifie que ton fournisseur
  Postgres autorise les connexions depuis l'extérieur (Neon et Vercel
  Postgres le font par défaut ; un Postgres auto-hébergé derrière un
  pare-feu, non). `scripts/ssl.mjs` décide d'exiger TLS selon le nom
  d'hôte — teste sa logique isolément avec `npm test` si le doute porte
  là-dessus.
- **`psql: command not found`** → tu utilises encore l'ancienne version de
  ce projet (celle qui shellait vers `psql` pour parler à Postgres). Ce
  problème est corrigé dans la version actuelle : `scripts/db.mjs` utilise
  `pg` désormais, plus besoin de `psql` au moment du build. Vérifie que
  `scripts/db.mjs` importe bien `import pg from 'pg';` en haut du fichier.

Si aucun de ces cas ne correspond, copie le message d'erreur exact des
**Build Logs** Vercel (ou de la sortie de `npm run generate` en local) —
c'est le point de départ le plus rapide pour diagnostiquer autre chose.

## Structure

```
db/
  schema.sql               tables (pollsters, blocs, polls, poll_results)
  views.sql                v_poll_bloc_observations (agrégation SQL)
  seed.sql                 sondages sourcés au 30 août 2026
  insert_poll_template.sql modèle pour ajouter un sondage
lib/
  kalman.mjs                filtre de Kalman + lisseur RTS + fit de Q
  variance.mjs               variance d'observation par sondage
scripts/
  db.mjs                    accès Postgres via `pg` (JSON) — a besoin de `npm install`
  ssl.mjs                    décision TLS locale vs distante (aucune dépendance, testée isolément)
  chart.mjs                  génération SVG par bloc
  styles.mjs                  CSS du site (clair + sombre)
  generate.mjs               orchestration : DB -> Kalman -> dist/index.html
test/
  kalman.test.mjs            9 tests (filtre + variance), aucune dépendance
  db.test.mjs                 4 tests (décision TLS), aucune dépendance
METHODOLOGY.md               ce que le modèle fait, choix, limites
```

`npm test` (13 tests au total) ne touche jamais le réseau ni Postgres et ne
nécessite aucun `npm install` — seul `npm run generate` a besoin de `pg`.
