// Logique de décision TLS pour la connexion Postgres — isolée dans son
// propre fichier SANS dépendance (pas d'import de `pg`) pour rester
// testable même quand `pg` n'est pas installé (voir test/db.test.mjs).
//
// Neon / Vercel Postgres / Supabase exigent TLS, avec des chaînes de
// certificats que Node ne valide pas toujours nativement —
// `rejectUnauthorized: false` est le compromis standard pour ce cas (rien
// de sensible dans les données ici). Un Postgres local (dev) n'a en
// revanche souvent PAS TLS activé du tout : lui forcer une négociation TLS
// ferait échouer la connexion — c'est exactement ce qui a cassé la
// génération locale la première fois. On tranche donc sur le nom d'hôte,
// avec `sslmode=disable` comme échappatoire explicite dans tous les cas.

/**
 * @param {string} connectionString
 * @returns {false | {rejectUnauthorized: boolean}}
 */
export function resolveSslOption(connectionString) {
  if (connectionString.includes('sslmode=disable')) return false;
  let host = '';
  try {
    host = new URL(connectionString).hostname;
  } catch {
    // URL non standard (rare) : on suppose un hôte distant, plus sûr par défaut.
  }
  const isLocal = ['localhost', '127.0.0.1', '::1'].includes(host);
  if (isLocal) return connectionString.includes('sslmode=require') ? { rejectUnauthorized: false } : false;
  return { rejectUnauthorized: false };
}
