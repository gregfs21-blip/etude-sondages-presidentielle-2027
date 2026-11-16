// Accès Postgres via `pg`, le driver Node standard.
//
// Version précédente : ce script shellait vers le binaire `psql` pour
// éviter toute dépendance npm — un choix fait pour pouvoir développer et
// tester dans un bac à sable où le registre npm était bloqué. Problème
// découvert au déploiement : l'image de build de Vercel n'embarque PAS le
// client `psql` (ce n'est pas un environnement Postgres, juste Node), donc
// `npm run generate` y échouait systématiquement avec un
// `psql: command not found`, même avec DATABASE_URL correctement défini.
//
// `pg` est présent sur npm et s'installe normalement dans n'importe quel
// environnement de build Node standard, Vercel inclus — c'est le bon choix
// ici, pas un compromis. Les requêtes SQL elles-mêmes n'ont pas changé
// (toujours du json_agg/row_to_json côté Postgres) : seul le transport
// change, `pg` renvoie déjà les colonnes JSON comme des objets JS parsés.

import pg from 'pg';
import { resolveSslOption } from './ssl.mjs';

const { Client } = pg;

function requireDatabaseUrl() {
  const url = process.env.DATABASE_URL;
  if (!url) {
    throw new Error(
      "DATABASE_URL n'est pas défini. Sur Vercel : Project Settings -> Environment " +
      "Variables (ou attache une base Postgres/Neon depuis l'onglet Storage, qui " +
      "l'injecte automatiquement). En local : `export DATABASE_URL=postgresql://...` " +
      "avant `npm run generate`."
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
export async function queryJson(sql) {
  const connectionString = requireDatabaseUrl();
  const client = new Client({
    connectionString,
    ssl: resolveSslOption(connectionString),
  });
  await client.connect();
  try {
    const result = await client.query(sql);
    const value = result.rows[0]?.[Object.keys(result.rows[0] ?? {})[0]];
    return value ?? [];
  } finally {
    await client.end();
  }
}

export async function getBlocs() {
  return (await queryJson(
    `select json_agg(row_to_json(b) order by b.sort_order) from blocs b;`
  )) ?? [];
}

/** Toutes les lignes (sondage x bloc), brutes ET agrégats de référence. */
export async function getAllObservations() {
  return (await queryJson(
    `select json_agg(row_to_json(v) order by v.bloc_sort_order, v.obs_date)
     from v_poll_bloc_observations v;`
  )) ?? [];
}
