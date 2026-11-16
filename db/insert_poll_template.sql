-- Modèle pour ajouter UN nouveau sondage. Copier ce fichier (ou l'exécuter
-- directement après édition), remplir les champs, exécuter :
--   psql "$DATABASE_URL" -f db/insert_poll_template.sql
-- puis régénérer le site : npm run generate

begin;

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'NOM_EXACT_DE_L_INSTITUT'),  -- doit déjà exister dans `pollsters`
  'Média commanditaire',
  '2026-09-01',  -- début terrain (ou NULL si inconnu)
  '2026-09-02',  -- fin terrain (ou NULL)
  '2026-09-05',  -- date de publication (obligatoire)
  1000,          -- taille d'échantillon (ou NULL si non publiée)
  'raw',         -- 'raw' pour un sondage normal, 'aggregate_reference' pour une moyenne tierce
  'https://...', -- URL de la source — obligatoire, jamais de sondage sans source
  null           -- notes libres (hypothèses testées, réserves, etc.)
);

-- Une ligne par (bloc, figure testée). Répéter pour chaque bloc concerné —
-- voir `blocs` pour les id valides : rn, centre, lfi, gauche, droite, autres.
insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'NomCandidat', 33.0, 33.0, 33.0
from polls where source_url = 'https://...';  -- même URL que ci-dessus

commit;

-- Pour ajouter un institut qui n'existe pas encore :
-- insert into pollsters (name, notes) values ('Nouvel institut', null);
