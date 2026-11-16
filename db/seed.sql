-- Données de départ (30 août 2026). Chaque source est un sondage
-- effectivement publié et citée par son URL — voir source_url sur chaque
-- ligne `polls`. Rien n'est inventé : quand un institut n'a pas publié de
-- chiffre exploitable pour un bloc (ex. OpinionWay/JDD sur la gauche), la
-- ligne est simplement absente plutôt que devinée.

begin;

-- ---------------------------------------------------------------------
-- Blocs (couleurs = palette catégorielle validée CVD du tracker existant)
-- ---------------------------------------------------------------------
insert into blocs (id, label, description, color_hex, color_hex_dark, sort_order) values
  ('rn',      'RN',                     'Le Pen ou Bardella (hypothèses alternatives, jamais testées ensemble)', '#eb6834', '#d95926', 1),
  ('centre',  'Centre',                 'Philippe, Attal, Bayrou : figures non déclarées du bloc central',       '#2a78d6', '#3987e5', 2),
  ('lfi',     'LFI',                    'Mélenchon',                                                              '#e87ba4', '#d55181', 3),
  ('gauche',  'Gauche mod. / écolo',    'Glucksmann, Tondelier, Roussel',                                        '#1baf7a', '#199e70', 4),
  ('droite',  'Droite classique',       'Retailleau (LR)',                                                       '#eda100', '#c98500', 5),
  ('autres',  'Autres',                 'Hollande, Zemmour, Dupont-Aignan, etc.',                                '#4a3aa7', '#9085e9', 6);

-- ---------------------------------------------------------------------
-- Instituts
-- ---------------------------------------------------------------------
insert into pollsters (name, notes) values
  ('Odoxa-Mascaret', null),
  ('Ipsos', null),
  ('OpinionWay', null),
  ('Toluna', null),
  ('Elabe (agrégat EPOC Info)', 'Moyenne glissante multi-instituts publiée par EPOC Info (Elabe, IFOP, Harris Interactive, Ipsos-BVA), pas un institut au sens strict.');

-- ---------------------------------------------------------------------
-- Sondage 1 — Odoxa-Mascaret, 26 mai 2026
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Odoxa-Mascaret'),
  'Public Sénat', '2026-05-20', '2026-05-21', '2026-05-26', 1005, 'raw',
  'https://www.publicsenat.fr/actualites/politique/presidentielle-2027-melenchon-et-philippe-au-coude-a-coude-pour-la-qualification-au-second-tour-bardella-toujours-largement-en-tete-selon-le-sondage-odoxa',
  'Sponsor inféré du média qui a commandé/rapporté le sondage, non confirmé comme commanditaire exclusif.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Bardella', 32.0, 32.0, 32.0 from polls where source_url like '%odoxa%'
union all select id, 'centre', 'Philippe', 17.0, 17.0, 17.0 from polls where source_url like '%odoxa%'
union all select id, 'lfi', 'Mélenchon', 16.0, 16.0, 16.0 from polls where source_url like '%odoxa%'
union all select id, 'gauche', 'Glucksmann', 11.0, 11.0, 11.0 from polls where source_url like '%odoxa%';

-- ---------------------------------------------------------------------
-- Sondage 2 — Ipsos pour Le Parisien, 1er juin 2026 (8 hypothèses)
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Ipsos'),
  'Le Parisien', '2026-05-27', '2026-05-28', '2026-06-01', 1500, 'raw',
  'https://www.ipsos.com/fr-fr/presidentielle-2027-les-candidats-du-rassemblement-national-largement-en-tete-au-premier-tour',
  '8 configurations de premier tour testées ; fourchettes basses-hautes tous scénarios confondus par figure.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Bardella', 31.0, 36.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'rn', 'Le Pen', 31.0, 36.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'centre', 'Philippe', 13.0, 19.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'centre', 'Attal', 8.5, 17.5, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'lfi', 'Mélenchon', 13.0, 13.5, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'gauche', 'Glucksmann', 11.0, 14.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'droite', 'Retailleau', 7.5, 10.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'autres', 'Hollande', 7.0, 8.0, null::numeric from polls where source_url like '%ipsos%'
union all select id, 'autres', 'Tondelier', 4.5, 5.5, 5.0 from polls where source_url like '%ipsos%';

-- ---------------------------------------------------------------------
-- Sondage 3 — OpinionWay pour Le JDD, juin 2026
-- Date de publication exacte non retrouvée dans nos sources : mi-juin
-- retenue par défaut (voir notes). Seul le bloc RN a un chiffre publié
-- exploitable dans les articles disponibles — les autres blocs ne sont
-- pas chiffrés dans nos sources et ne sont donc PAS renseignés (mieux
-- vaut une absence qu'un chiffre inventé).
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'OpinionWay'),
  'Le JDD', null, null, '2026-06-15', null, 'raw',
  'https://www.opinion-way.com/fr/publications/les-intentions-de-vote-a-lelection-presidentielle-de-2027-2026-23706/',
  'Date de publication estimée (mi-juin 2026) : la date exacte n''apparaît pas dans le contenu accessible de la source. Seul le score RN était chiffré dans nos sources ; Glucksmann/Mélenchon décrits comme "au coude-à-coude" sans pourcentages publiés.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'RN (Le Pen ou Bardella, hypothèse non détaillée)', 33.0, 35.0, null::numeric from polls where source_url like '%opinion-way%';

-- ---------------------------------------------------------------------
-- Sondage 4 — Toluna pour M6/RTL, vague 4, 24 août 2026
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Toluna'),
  'M6 / RTL', '2026-08-18', '2026-08-19', '2026-08-24', 1764, 'raw',
  'https://tolunacorporate.com/fr/intentions-de-vote-a-lelection-presidentielle-2027-3/',
  'Vague 4 du baromètre Toluna-M6-RTL. 5 hypothèses testées.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen', 35.0, 38.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'centre', 'Philippe', 14.0, 19.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'centre', 'Attal', 8.0, 15.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'lfi', 'Mélenchon', 16.0, 17.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'gauche', 'Glucksmann', 10.0, 11.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'droite', 'Retailleau', 6.0, 9.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'autres', 'Hollande', 8.0, 8.0, 8.0 from polls where source_url like '%tolunacorporate%'
union all select id, 'autres', 'Roussel', 2.0, 3.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'autres', 'Tondelier', 2.0, 5.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'autres', 'Zemmour', 3.0, 4.0, null::numeric from polls where source_url like '%tolunacorporate%'
union all select id, 'autres', 'Dupont-Aignan', 2.0, 3.0, null::numeric from polls where source_url like '%tolunacorporate%';

-- ---------------------------------------------------------------------
-- Référence 5 — Elabe / EPOC Info, moyenne agrégée, 29 août 2026
-- poll_type = 'aggregate_reference' : jamais lue par le pipeline Kalman
-- (voir scripts/fetch_observations.mjs), affichée uniquement à titre de
-- recoupement dans le journal des sondages.
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Elabe (agrégat EPOC Info)'),
  null, '2026-02-01', '2026-08-29', '2026-08-29', null, 'aggregate_reference',
  'https://www.epocinfo.fr/ep2027.php',
  'Moyenne glissante multi-instituts février-août 2026, composée en partie des sondages déjà présents individuellement dans cette base : exclue du filtre pour éviter un double comptage.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Bardella', 35.0, 35.0, 35.0 from polls where source_url like '%epocinfo%'
union all select id, 'rn', 'Le Pen', 34.0, 34.0, 34.0 from polls where source_url like '%epocinfo%'
union all select id, 'centre', 'Philippe', 18.2, 18.2, 18.2 from polls where source_url like '%epocinfo%'
union all select id, 'centre', 'Attal', 13.5, 13.5, 13.5 from polls where source_url like '%epocinfo%'
union all select id, 'lfi', 'Mélenchon', 13.8, 13.8, 13.8 from polls where source_url like '%epocinfo%';

commit;
