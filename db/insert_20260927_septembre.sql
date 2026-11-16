-- Sondages ajoutés le 27 septembre 2026 (mise à jour hebdomadaire lancée
-- manuellement par l'utilisateur, la tâche planifiée n'avait pas encore
-- tourné au moment de la demande). Sondages parus entre le 14 et le 21
-- septembre 2026 (date de dernière vérification précédente), sourcés
-- individuellement.
--
-- Sondages examinés mais délibérément écartés (chiffres de premier tour
-- non retrouvés dans une source primaire ou secondaire fiable malgré
-- plusieurs recherches) : Odoxa/Le Figaro du 16 septembre 2026 (réf.
-- commission des sondages 10267 — PDF source inaccessible depuis ce
-- sandbox, aucun article de presse retrouvé avec les chiffres détaillés) ;
-- IFOP/Paris Match du 22 septembre 2026 (réf. 10271 — probable baromètre
-- de popularité plutôt qu'intentions de vote au 1er tour, non confirmé).
-- Ces deux sondages sont à revérifier lors d'une prochaine mise à jour.

begin;

insert into pollsters (name, notes) values
  ('Cluster17', null)
  on conflict (name) do nothing;

-- ---------------------------------------------------------------------
-- Sondage 9 — Cluster17 pour Le Point, terrain 31 août-1er sept. 2026,
-- publié ~5 septembre 2026 (3 scénarios, estimations ponctuelles par
-- scénario).
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Cluster17'),
  'Le Point', '2026-08-31', '2026-09-01', '2026-09-05', 1628, 'raw',
  'https://cluster17.com/wp-content/uploads/2026/09/C17_Le_Point_Sondage_Election_Presidentielle_2027_Sep26-.pdf',
  '3 scénarios testés. Échantillon électeurs inscrits 1628 (sur 1711 interrogés). Scores ponctuels par scénario, effectifs utiles différents par scénario (1150/1131/1211) mais non pondérés ici faute de détail suffisant.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen (scénario 1)', 30.0, 30.0, 30.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'rn', 'Le Pen (scénario 2)', 31.5, 31.5, 31.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'rn', 'Le Pen (scénario 3)', 29.0, 29.0, 29.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'centre', 'Philippe (scénario 1)', 18.0, 18.0, 18.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'centre', 'Attal (scénario 2)', 13.5, 13.5, 13.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'centre', 'Philippe (scénario 3)', 17.0, 17.0, 17.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'lfi', 'Mélenchon (scénario 1)', 18.0, 18.0, 18.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'lfi', 'Mélenchon (scénario 2)', 18.0, 18.0, 18.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'lfi', 'Mélenchon (scénario 3)', 17.0, 17.0, 17.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'lfi', 'Ruffin (scénario 3)', 4.0, 4.0, 4.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'gauche', 'Glucksmann (scénario 1)', 11.5, 11.5, 11.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'gauche', 'Glucksmann (scénario 2)', 11.5, 11.5, 11.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'gauche', 'Glucksmann (scénario 3)', 11.0, 11.0, 11.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'droite', 'Retailleau (scénario 1)', 7.5, 7.5, 7.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'droite', 'Retailleau (scénario 2)', 9.0, 9.0, 9.0 from polls where source_url like '%C17_Le_Point%'
union all select id, 'droite', 'Retailleau (scénario 3)', 6.5, 6.5, 6.5 from polls where source_url like '%C17_Le_Point%'
union all select id, 'droite', 'Lisnard (scénario 3)', 4.0, 4.0, 4.0 from polls where source_url like '%C17_Le_Point%';

-- ---------------------------------------------------------------------
-- Sondage 10 — Toluna Harris Interactive pour M6/RTL, terrain 8-10 sept.
-- 2026, publié 14 septembre 2026 (5 hypothèses, fourchettes tous
-- scénarios confondus par figure telles que rapportées par l'article).
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Toluna'),
  'M6 / RTL', '2026-09-08', '2026-09-10', '2026-09-14', 2052, 'raw',
  'https://tolunacorporate.com/fr/intentions-de-vote-a-lelection-presidentielle-2027-septembre-2026/',
  '5 hypothèses de 1er tour testées ; fourchettes basses-hautes tous scénarios confondus par figure (article ne détaille pas chaque combinaison). Hollande et Zemmour rapportés comme scores ponctuels uniques (pas de fourchette).'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen', 33.0, 36.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'centre', 'Philippe', 14.0, 19.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'centre', 'Attal', 8.0, 15.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'lfi', 'Mélenchon', 16.0, 17.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'gauche', 'Glucksmann', 10.0, 12.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'droite', 'Retailleau', 7.0, 10.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'autres', 'Hollande', 7.0, 7.0, 7.0 from polls where source_url like '%septembre-2026%'
union all select id, 'autres', 'Zemmour', 5.0, 5.0, 5.0 from polls where source_url like '%septembre-2026%'
union all select id, 'autres', 'Dupont-Aignan', 2.0, 3.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'autres', 'Roussel', 2.0, 3.0, null::numeric from polls where source_url like '%septembre-2026%'
union all select id, 'autres', 'Tondelier', 3.0, 4.0, null::numeric from polls where source_url like '%septembre-2026%';

commit;
