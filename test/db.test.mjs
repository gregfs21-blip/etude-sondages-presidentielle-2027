import { test } from 'node:test';
import assert from 'node:assert/strict';
import { resolveSslOption } from '../scripts/ssl.mjs';

// Ces tests ne se connectent à aucune base et n'importent PAS scripts/db.mjs
// (qui charge `pg`) : la logique de décision TLS vit dans son propre
// fichier sans dépendance exprès pour ça. Elle a directement causé un
// échec de connexion la première fois (Postgres local sans TLS, option ssl
// forcée à tort) — d'où des tests dédiés plutôt qu'une simple relecture.

test('resolveSslOption: local sans sslmode -> pas de TLS forcé', () => {
  assert.equal(resolveSslOption('postgresql://u:p@localhost:5432/db'), false);
  assert.equal(resolveSslOption('postgresql://u:p@127.0.0.1:5432/db'), false);
});

test('resolveSslOption: hôte distant -> TLS avec certificat permissif', () => {
  const opt = resolveSslOption('postgresql://u:p@ep-xyz.neon.tech:5432/db?sslmode=require');
  assert.deepEqual(opt, { rejectUnauthorized: false });
});

test('resolveSslOption: sslmode=disable explicite gagne toujours', () => {
  assert.equal(resolveSslOption('postgresql://u:p@ep-xyz.neon.tech:5432/db?sslmode=disable'), false);
});

test('resolveSslOption: local avec sslmode=require explicite -> TLS quand même', () => {
  const opt = resolveSslOption('postgresql://u:p@localhost:5432/db?sslmode=require');
  assert.deepEqual(opt, { rejectUnauthorized: false });
});
