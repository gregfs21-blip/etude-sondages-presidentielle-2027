// Accès Postgres SANS driver npm : on shelle out vers `psql`, qui doit
// être présent sur la machine qui exécute `npm run generate` (c'est le cas
// de toute machine dev standard, et ça évite une dépendance npm pour un
// script qui tourne quelques fois par mois). Voir README.md pour le
// choix architectural.
//
// psql renvoie du JSON produit CÔTÉ POSTGRES (json_agg/row_to_json) :
// pas de parsing CSV fait maison, pas d'ambiguïté de types.

import { spawnSync } from 'node:child_process';

function requireDatabaseUrl() {
  const url = process.env.DATABASE_URL;
  if (!url) {
    throw new Error(
      "DATABASE_URL n'est pas défini. Exporte l'URL de connexion Postgres avant de lancer " +
      "`npm run generate` (voir README.md — Neon/Vercel Postgres fournissent cette URL directement)."
    );
  }
  return url;
}

/**
 * Exécute une requête et renvoie le résultat JSON déjà parsé.
 * La requête DOIT renvoyer une seule colonne/une seule ligne contenant du
 * JSON (typiquement via `json_agg(row_to_json(...))`).
 * @param {string} sql
 */
export function queryJson(sql) {
  const databaseUrl = requireDatabaseUrl();
  const result = spawnSync(
    'psql',
    [databaseUrl, '-v', 'ON_ERROR_STOP=1', '-t', '-A', '-q', '-c', sql],
    { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 }
  );
  if (result.error) {
    if (result.error.code === 'ENOENT') {
      throw new Error(
        "La commande `psql` est introuvable dans ce PATH. Installe le client Postgres " +
        "(ex. `apt install postgresql-client` / `brew install libpq`) pour exécuter ce script."
      );
    }
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`psql a échoué (code ${result.status}):\n${result.stderr}`);
  }
  const out = result.stdout.trim();
  if (out === '' || out === '(null)') return [];
  return JSON.parse(out);
}

export function getBlocs() {
  return queryJson(
    `select json_agg(row_to_json(b) order by b.sort_order)
     from blocs b;`
  ) ?? [];
}

/** Toutes les lignes (sondage x bloc), brutes ET agrégats de référence. */
export function getAllObservations() {
  return queryJson(
    `select json_agg(row_to_json(v) order by v.bloc_sort_order, v.obs_date)
     from v_poll_bloc_observations v;`
  ) ?? [];
}
