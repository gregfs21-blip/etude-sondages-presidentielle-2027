-- Sondage ajouté le 4 octobre 2026 (exécution automatique planifiée).
-- Toluna Harris Interactive pour M6/RTL, "Baromètre Présidentielle 2027,
-- vague 6", terrain 22-24 septembre 2026, publié 28 septembre 2026
-- (registre commission des sondages, notice 10277). Source : PDF de
-- l'institut lui-même (chargeable directement depuis le sandbox, contrairement
-- aux notices PDF individuelles de la commission) :
--   https://tolunacorporate.com/wp-content/uploads/2026/09/Rapport-Toluna-Barometre-Presidentielle-2027-Vague-6-M6-RTL-28-septembre-2026.pdf
-- 5 hypothèses testées, chacune vérifiée à somme = 100 % dans le PDF.
--
-- Encodage bloc 'centre' pour l'hypothèse 1 ("Glucksmann + Attal + Philippe") :
-- Attal (5 %) ET Philippe (13 %) sont tous deux candidats dans cette
-- hypothèse (scénario de centre divisé). Règle du 27 septembre (une figure
-- principale par bloc et par scénario) appliquée : seul Philippe (score le
-- plus élevé) est saisi, Attal (5 %, co-candidat secondaire du même bloc
-- dans le même scénario) est omis — même traitement que le cas
-- Attal+Philippe d'OpinionWay/CNews corrigé le 27 septembre.
--
-- Bloc 'autres' : agrégat volontaire de petits candidats distincts par
-- hypothèse (Arthaud, Roussel, Tondelier, Dupont-Aignan, Zemmour, et
-- Hollande quand il remplace Glucksmann en H4/H5) — comportement assumé du
-- bloc 'autres', pas une erreur (voir METHODOLOGY.md et le correctif du
-- 27 septembre : "autres" moyenne plusieurs petits candidats, c'est voulu).
--
-- Sondages examinés la même semaine mais écartés faute de source fiable
-- vérifiable depuis ce sandbox automatique (voir claude/suivi-sondages-2027.md
-- pour le détail) : IFOP-Fiducial/Le Figaro-LCI-Sud Radio (notice 10284,
-- terrain 25-29 sept., chiffres contradictoires entre deux sources
-- secondaires indépendantes sur les mêmes scénarios) ; CSA/Cnews (notices
-- 10278 et 10279) nature non confirmée ; Odoxa (x3), Verian, Elabe (x3),
-- YouGov baromètre popularité : baromètres/questions thématiques, pas des
-- intentions de vote 1er tour.

begin;

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Toluna'),
  'M6 / RTL', '2026-09-22', '2026-09-24', '2026-09-28', 1974, 'raw',
  'https://tolunacorporate.com/wp-content/uploads/2026/09/Rapport-Toluna-Barometre-Presidentielle-2027-Vague-6-M6-RTL-28-septembre-2026.pdf',
  'Vague 6 du baromètre Toluna Harris Interactive - M6/RTL. 5 hypothèses testées, chacune vérifiée à somme = 100 % dans le PDF institut. Hypothèse 1 : Attal (5 %), co-candidat secondaire face à Philippe (13 %) dans le même scénario centre, non saisi (règle du 27 septembre).'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
-- RN (Le Pen, les 5 hypothèses)
select id, 'rn', 'Le Pen (H1)', 35.0, 35.0, 35.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'rn', 'Le Pen (H2)', 35.0, 35.0, 35.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'rn', 'Le Pen (H3)', 36.0, 36.0, 36.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'rn', 'Le Pen (H4)', 35.0, 35.0, 35.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'rn', 'Le Pen (H5)', 36.0, 36.0, 36.0 from polls where source_url like '%Vague-6-M6-RTL%'
-- Centre (figure principale par hypothèse)
union all select id, 'centre', 'Philippe (H1)', 13.0, 13.0, 13.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'centre', 'Philippe (H2)', 16.0, 16.0, 16.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'centre', 'Attal (H3)', 12.0, 12.0, 12.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'centre', 'Philippe (H4)', 16.0, 16.0, 16.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'centre', 'Attal (H5)', 13.0, 13.0, 13.0 from polls where source_url like '%Vague-6-M6-RTL%'
-- LFI (Mélenchon)
union all select id, 'lfi', 'Mélenchon (H1)', 17.0, 17.0, 17.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (H2)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (H3)', 17.0, 17.0, 17.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (H4)', 18.0, 18.0, 18.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'lfi', 'Mélenchon (H5)', 17.0, 17.0, 17.0 from polls where source_url like '%Vague-6-M6-RTL%'
-- Gauche mod. / écolo (Glucksmann, présent en H1-H3 seulement ; H4/H5 testent Hollande à la place, voir 'autres')
union all select id, 'gauche', 'Glucksmann (H1)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'gauche', 'Glucksmann (H2)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'gauche', 'Glucksmann (H3)', 11.0, 11.0, 11.0 from polls where source_url like '%Vague-6-M6-RTL%'
-- Droite classique (Retailleau)
union all select id, 'droite', 'Retailleau (H1)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'droite', 'Retailleau (H2)', 8.0, 8.0, 8.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'droite', 'Retailleau (H3)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'droite', 'Retailleau (H4)', 9.0, 9.0, 9.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'droite', 'Retailleau (H5)', 10.0, 10.0, 10.0 from polls where source_url like '%Vague-6-M6-RTL%'
-- Autres (agrégat de petits candidats distincts, par hypothèse — comportement assumé du bloc)
union all select id, 'autres', 'Arthaud (H1)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Roussel (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Tondelier (H1)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Zemmour (H1)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Arthaud (H2)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Roussel (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Tondelier (H2)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Zemmour (H2)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Arthaud (H3)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Roussel (H3)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Tondelier (H3)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (H3)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Zemmour (H3)', 6.0, 6.0, 6.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Arthaud (H4)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Roussel (H4)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Tondelier (H4)', 4.0, 4.0, 4.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (H4)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Zemmour (H4)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Hollande (H4)', 7.0, 7.0, 7.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Arthaud (H5)', 1.0, 1.0, 1.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Roussel (H5)', 3.0, 3.0, 3.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Tondelier (H5)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Dupont-Aignan (H5)', 2.0, 2.0, 2.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Zemmour (H5)', 5.0, 5.0, 5.0 from polls where source_url like '%Vague-6-M6-RTL%'
union all select id, 'autres', 'Hollande (H5)', 8.0, 8.0, 8.0 from polls where source_url like '%Vague-6-M6-RTL%';

commit;
