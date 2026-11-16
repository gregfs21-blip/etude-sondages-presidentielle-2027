-- Sondages ajoutés le 18 octobre 2026 (exécution automatique planifiée).
-- Recherche initiale via un fork de recherche approfondie restée bloquée
-- plus d'une heure sans retour (voir note dans claude/suivi-sondages-2027.md) ;
-- cette session a donc fait elle-même une recherche ciblée (WebSearch standard/
-- extended + WebFetch des PDF instituts) pour la fenêtre du 11 au 18 octobre 2026.
--
-- Deux sondages retenus, tous deux vérifiés sur le PDF de l'institut lui-même,
-- chaque hypothèse sommant à 100 % dans le document source :
--
-- 1. Odoxa-Backbone pour Public Sénat, la presse régionale et Le Nouvel Obs,
--    terrain 24 septembre-7 octobre 2026, publié le 15 octobre 2026, n=12 005.
--    PDF : https://www.odoxa.fr/wp-content/uploads/2026/10/Odoxa-Backbone-pour-la-Presse-Regionale-Public-Senat-et-le-Nouvel-Obs-IV-a-lelection-presidentielle-de-2027.pdf
--    2 hypothèses : H1 Philippe candidat, H2 Attal candidat.
--
-- 2. Toluna Harris Interactive pour M6/RTL, baromètre vague 7, terrain
--    5-8 octobre 2026, publié le 12 octobre 2026, n=2 004.
--    PDF : https://tolunacorporate.com/wp-content/uploads/2026/10/Rapport-Toluna-Barometre-Presidentielle-2027-Vague-7-M6-RTL-12-octobre-2026.pdf
--    5 hypothèses : A (Glucksmann+Attal+Philippe), B (Glucksmann+Philippe),
--    C (Glucksmann+Attal), D (Hollande+Philippe), E (Hollande+Attal).
--
-- Conventions appliquées (cohérence avec le reste de la base, voir
-- METHODOLOGY.md et claude/suivi-sondages-2027.md) :
--   - Bloc 'gauche' : SEUL Glucksmann y est saisi. Tondelier et Roussel,
--     bien que nominalement dans la description du bloc, vont dans 'autres'
--     (convention de fait établie le 27 septembre, conservée pour la
--     cohérence de la série malgré l'incohérence d'étiquetage).
--   - Règle du 27 septembre : UNE figure principale par bloc et par scénario.
--     Toluna hypothèse A teste Philippe (13 %) ET Attal (5 %) tous deux dans
--     le même scénario centre divisé : seul Philippe (score le plus élevé)
--     est saisi, Attal omis.
--   - Hollande (remplaçant Glucksmann comme figure PS-PP alternative dans les
--     hypothèses D et E de Toluna) va dans 'autres', par cohérence avec les
--     saisies précédentes (IFOP du 11 oct., etc.).
--
-- Sondage trouvé mais ÉCARTÉ faute de source primaire vérifiable : un
-- troisième sondage (Ifop-Fiducial pour LCI/Le Figaro/Sud Radio, terrain
-- 12-14 octobre 2026, n=1390, mentionné via l'article secondaire
-- economiematin.fr du 2026-10-18 citant les scénarios centre Philippe/Attal)
-- n'a pas pu être retrouvé sous forme de PDF institut malgré plusieurs
-- recherches (ifop.com, ifopgroup.com) ; l'article secondaire ne donne pas le
-- score RN pour les scénarios centre et les chiffres sont incomplets/ambigus.
-- Non ajouté — à rechercher en priorité lors d'une prochaine exécution
-- (chercher un PDF "vague 7" ou "vague 8" Ifop-Fiducial LCI/Figaro/Sud Radio,
-- probablement publié autour du 15-18 octobre 2026).
--
-- Un autre sondage, Toluna-Harris Interactive mentionné par economiematin.fr
-- avec un chiffre "Philippe 47%" ambigu, correspond en réalité au SECOND TOUR
-- de la vague 7 ci-dessus (Philippe 44% contre Le Pen 56% dans le PDF primaire,
-- pas 47% — la source secondaire était imprécise) : le second tour n'est pas
-- suivi par ce pipeline (premier tour uniquement), donc sans conséquence ici.

begin;

insert into pollsters (name, notes) values
  ('Odoxa-Backbone', 'Partenariat Odoxa / Backbone (indice de dynamique de campagne) pour Public Sénat, la presse régionale et Le Nouvel Obs. Distinct de ''Odoxa-Mascaret'' (sondage de mai 2026, partenariat différent).')
  on conflict (name) do nothing;

-- ---------------------------------------------------------------------
-- Sondage 15 — Odoxa-Backbone / Public Sénat, presse régionale, Le Nouvel
-- Obs, terrain 24 sept.-7 oct. 2026, publié 15 oct. 2026, n=12 005.
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Odoxa-Backbone'),
  'Public Sénat / presse régionale / Le Nouvel Obs',
  '2026-09-24', '2026-10-07', '2026-10-15', 12005, 'raw',
  'https://www.odoxa.fr/wp-content/uploads/2026/10/Odoxa-Backbone-pour-la-Presse-Regionale-Public-Senat-et-le-Nouvel-Obs-IV-a-lelection-presidentielle-de-2027.pdf',
  '2 hypothèses testées (H1 Philippe candidat, H2 Attal candidat), chacune vérifiée à somme = 100 % dans le PDF institut. Marge d''erreur annoncée : ±0,6 à ±1,2 point (IC 95%). Bardella non testé dans ce sondage (seulement en mai 2026, à la place de Le Pen, selon le document). Tondelier et Roussel rangés dans ''autres'', par cohérence avec la convention du 27 septembre.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen (H1)', 37.0, 37.0, 37.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'rn', 'Le Pen (H2)', 38.0, 38.0, 38.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'lfi', 'Mélenchon (H1)', 18.0, 18.0, 18.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'lfi', 'Mélenchon (H2)', 18.5, 18.5, 18.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'centre', 'Philippe (H1)', 17.0, 17.0, 17.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'centre', 'Attal (H2)', 11.0, 11.0, 11.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'gauche', 'Glucksmann (H1)', 9.5, 9.5, 9.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'gauche', 'Glucksmann (H2)', 10.5, 10.5, 10.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'droite', 'Retailleau (H1)', 6.5, 6.5, 6.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'droite', 'Retailleau (H2)', 9.0, 9.0, 9.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Zemmour (H1)', 4.5, 4.5, 4.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Tondelier (H1)', 3.0, 3.0, 3.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Roussel (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Dupont-Aignan (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Arthaud (H1)', 0.5, 0.5, 0.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Tondelier (H2)', 3.5, 3.5, 3.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Zemmour (H2)', 4.5, 4.5, 4.5 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Roussel (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Dupont-Aignan (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%'
union all select id, 'autres', 'Arthaud (H2)', 1.0, 1.0, 1.0 from polls where source_url like '%Odoxa-Backbone-pour-la-Presse%';

-- ---------------------------------------------------------------------
-- Sondage 16 — Toluna Harris Interactive / M6-RTL, baromètre vague 7,
-- terrain 5-8 oct. 2026, publié 12 oct. 2026, n=2 004.
-- ---------------------------------------------------------------------
insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Toluna'),
  'M6 / RTL', '2026-10-05', '2026-10-08', '2026-10-12', 2004, 'raw',
  'https://tolunacorporate.com/wp-content/uploads/2026/10/Rapport-Toluna-Barometre-Presidentielle-2027-Vague-7-M6-RTL-12-octobre-2026.pdf',
  'Vague 7 du baromètre Toluna Harris Interactive - M6/RTL. 5 hypothèses testées (A à E), chacune vérifiée à somme = 100 % dans le PDF institut. Hypothèse A : Philippe (13 %) et Attal (5 %) tous deux candidats dans le même scénario centre divisé ; seul Philippe (score le plus élevé) est saisi, Attal omis (règle du 27 septembre). Hypothèses D et E : Hollande remplace Glucksmann comme figure PS-PP alternative, rangé dans ''autres'' par cohérence. Bardella non testé (apparaît seulement dans des traits d''image comparés à Le Pen, pas dans les intentions de vote). Bayrou non testé.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
-- RN (Le Pen, les 5 hypothèses)
select id, 'rn', 'Le Pen (A)', 35.0, 35.0, 35.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'rn', 'Le Pen (B)', 36.0, 36.0, 36.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'rn', 'Le Pen (C)', 36.0, 36.0, 36.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'rn', 'Le Pen (D)', 36.0, 36.0, 36.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'rn', 'Le Pen (E)', 37.0, 37.0, 37.0 from polls where source_url like '%Vague-7-M6-RTL%'
-- LFI (Mélenchon)
union all select id, 'lfi', 'Mélenchon (A)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (B)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (C)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (D)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (E)', 19.0, 19.0, 19.0 from polls where source_url like '%Vague-7-M6-RTL%'
-- Centre (figure principale par hypothèse ; Attal omis en (A), co-candidat secondaire face à Philippe)
union all select id, 'centre', 'Philippe (A)', 13.0, 13.0, 13.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'centre', 'Philippe (B)', 17.0, 17.0, 17.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'centre', 'Attal (C)', 12.0, 12.0, 12.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'centre', 'Philippe (D)', 17.0, 17.0, 17.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'centre', 'Attal (E)', 12.0, 12.0, 12.0 from polls where source_url like '%Vague-7-M6-RTL%'
-- Gauche mod. / écolo (Glucksmann seulement, présent en A, B, C ; absent en D/E où Hollande le remplace)
union all select id, 'gauche', 'Glucksmann (A)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'gauche', 'Glucksmann (B)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'gauche', 'Glucksmann (C)', 11.0, 11.0, 11.0 from polls where source_url like '%Vague-7-M6-RTL%'
-- Droite classique (Retailleau)
union all select id, 'droite', 'Retailleau (A)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'droite', 'Retailleau (B)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'droite', 'Retailleau (C)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'droite', 'Retailleau (D)', 8.0, 8.0, 8.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'droite', 'Retailleau (E)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-7-M6-RTL%'
-- Autres (agrégat de petits candidats distincts par hypothèse + Hollande en D/E + Tondelier/Roussel par convention)
union all select id, 'autres', 'Zemmour (A)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Roussel (A)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Tondelier (A)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (A)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Arthaud (A)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Tondelier (B)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Zemmour (B)', 4.0, 4.0, 4.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Roussel (B)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (B)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Arthaud (B)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Zemmour (C)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Tondelier (C)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Roussel (C)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (C)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Arthaud (C)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Hollande (D)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Tondelier (D)', 4.0, 4.0, 4.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Zemmour (D)', 4.0, 4.0, 4.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Roussel (D)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (D)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Arthaud (D)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Hollande (E)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Tondelier (E)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Zemmour (E)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Roussel (E)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (E)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-7-M6-RTL%'
union all select id, 'autres', 'Arthaud (E)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-7-M6-RTL%';

commit;
