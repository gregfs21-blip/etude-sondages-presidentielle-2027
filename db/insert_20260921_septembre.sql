-- Sondages ajoutés le 21 septembre 2026 (rattrapage suite à l'incident du
-- 20 septembre : la session programmée hebdomadaire a échoué avant
-- d'aboutir, voir claude/suivi-sondages-2027.md). Sondages parus entre le
-- 30 août et le 21 septembre 2026, sourcés individuellement avec URL
-- directe et chiffres explicites. D'autres sondages ont été publiés sur
-- cette période (ex. OpinionWay/CNews du 11 septembre) mais n'ont pas été
-- retenus faute d'avoir pu en vérifier les chiffres détaillés dans une
-- source accessible — absence préférée à une valeur devinée.

begin;

-- ---------------------------------------------------------------------
-- Sondage 6 — Ipsos pour Le Parisien, 5 septembre 2026
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Ipsos'),
  'Le Parisien', '2026-08-31', '2026-09-02', '2026-09-05', 1500, 'raw',
  'https://www.ipsos.com/fr-fr/presidentielle-2027-marine-le-pen-conserve-une-avance-nette-dans-les-intentions-de-vote',
  '6 configurations de premier tour testées ; fourchettes basses-hautes tous scénarios confondus par figure.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen', 34.0, 36.0, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'centre', 'Philippe', 14.5, 16.5, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'centre', 'Attal', 7.5, 8.5, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'lfi', 'Mélenchon', 15.0, 17.0, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'gauche', 'Glucksmann', 11.5, 14.0, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'droite', 'Retailleau', 6.0, 10.0, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%'
union all select id, 'autres', 'Faure', 4.5, 5.5, null::numeric from polls where source_url like '%avance-nette-dans-les-intentions%';

-- ---------------------------------------------------------------------
-- Sondage 7 — OpinionWay pour CNews, 6 septembre 2026 (3 scénarios,
-- estimations ponctuelles publiées par scénario, pas de fourchette
-- rapportée institut par institut — chaque scénario est donc entré comme
-- son propre point, low=high=point).
-- Source : article Europe1 citant intégralement les 3 scénarios chiffrés
-- (page OpinionWay elle-même non nominative pour cette vague précise).
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'OpinionWay'),
  'CNews', '2026-09-02', '2026-09-03', '2026-09-06', 929, 'raw',
  'https://www.europe1.fr/politique/sondage-presidentielle-2027-marine-le-pen-assuree-detre-au-second-tour-et-de-lemporter-face-a-jean-luc-melenchon-1055162',
  '3 scénarios testés (candidature centre : Attal seul / Attal+Philippe / Philippe seul). Scores ponctuels par scénario, pas de fourchette publiée par figure.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen (scénario Attal seul)', 35.0, 35.0, 35.0 from polls where source_url like '%1055162%'
union all select id, 'rn', 'Le Pen (scénario Attal+Philippe)', 34.0, 34.0, 34.0 from polls where source_url like '%1055162%'
union all select id, 'rn', 'Le Pen (scénario Philippe seul)', 33.0, 33.0, 33.0 from polls where source_url like '%1055162%'
union all select id, 'lfi', 'Mélenchon (scénario Attal seul)', 17.0, 17.0, 17.0 from polls where source_url like '%1055162%'
union all select id, 'lfi', 'Mélenchon (scénario Attal+Philippe)', 17.0, 17.0, 17.0 from polls where source_url like '%1055162%'
union all select id, 'lfi', 'Mélenchon (scénario Philippe seul)', 16.0, 16.0, 16.0 from polls where source_url like '%1055162%'
union all select id, 'centre', 'Attal (scénario Attal seul)', 13.0, 13.0, 13.0 from polls where source_url like '%1055162%'
union all select id, 'centre', 'Philippe (scénario Attal+Philippe)', 15.0, 15.0, 15.0 from polls where source_url like '%1055162%'
union all select id, 'centre', 'Attal (scénario Attal+Philippe)', 7.0, 7.0, 7.0 from polls where source_url like '%1055162%'
union all select id, 'centre', 'Philippe (scénario Philippe seul)', 20.0, 20.0, 20.0 from polls where source_url like '%1055162%'
union all select id, 'gauche', 'Glucksmann (scénario Attal seul)', 13.0, 13.0, 13.0 from polls where source_url like '%1055162%'
union all select id, 'droite', 'Retailleau (scénario Attal seul)', 11.0, 11.0, 11.0 from polls where source_url like '%1055162%'
union all select id, 'droite', 'Retailleau (scénario Attal+Philippe)', 7.0, 7.0, 7.0 from polls where source_url like '%1055162%';

-- ---------------------------------------------------------------------
-- Sondage 8 — Enquête Électorale Française (Ipsos-BVA/CESI pour CEVIPOF,
-- Fondation Jean Jaurès, Institut Montaigne, Le Monde), 13 septembre 2026
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Ipsos'),
  'Le Monde (Enquête Électorale Française : Ipsos-BVA/CESI, CEVIPOF, Fondation Jean Jaurès, Institut Montaigne)',
  '2026-09-03', '2026-09-09', '2026-09-13', 13060, 'raw',
  'https://www.ipsos.com/fr-fr/presidentielle-2027-le-point-7-mois-du-scrutin',
  'Grande vague de l''Enquête Électorale Française (panel de 13 060 personnes inscrites sur les listes électorales). Fourchettes tous scénarios confondus par figure.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen', 33.0, 35.0, null::numeric from polls where source_url like '%7-mois-du-scrutin%'
union all select id, 'centre', 'Philippe', 14.0, 21.0, null::numeric from polls where source_url like '%7-mois-du-scrutin%'
union all select id, 'centre', 'Attal', 6.0, 15.5, null::numeric from polls where source_url like '%7-mois-du-scrutin%'
union all select id, 'lfi', 'Mélenchon', 15.5, 17.0, null::numeric from polls where source_url like '%7-mois-du-scrutin%'
union all select id, 'gauche', 'Glucksmann', 11.5, 13.5, null::numeric from polls where source_url like '%7-mois-du-scrutin%'
union all select id, 'droite', 'Retailleau', 7.0, 10.5, null::numeric from polls where source_url like '%7-mois-du-scrutin%';

commit;
