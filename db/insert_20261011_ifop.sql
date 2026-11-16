-- Sondage ajouté le 11 octobre 2026 (exécution automatique planifiée).
-- IFOP-Fiducial pour LCI, Le Figaro et Sud Radio, "Baromètre de l'élection
-- présidentielle, vague 6", terrain 25-29 septembre 2026, publié le
-- 30 septembre 2026 (registre commission des sondages, notice 10284).
--
-- CE SONDAGE ÉTAIT PRÉCÉDEMMENT ÉCARTÉ (voir claude/suivi-sondages-2027.md,
-- passes du 4 et 8 octobre) : deux sources secondaires trouvées alors se
-- contredisaient sur les mêmes scénarios. Cette session a trouvé la
-- notice/PDF de l'institut lui-même, hébergée sur ifopgroup.com :
--   https://www.ifopgroup.com/wp-content/uploads/2026/10/122802-resultats-densemble-1.pdf
-- 10 hypothèses testées (S1 à S10), chacune vérifiée à somme = 100 % dans
-- le document institut. Résout donc l'incertitude précédente — ajouté
-- avec la donnée primaire, comme demandé par les sessions précédentes.
--
-- Légende des hypothèses (telle que documentée par l'institut) :
--   S1  Philippe + Attal (centre divisé), Glucksmann (PS-PP)
--   S2  Philippe seul (centre), Glucksmann (PS-PP)
--   S3  Attal seul (centre), Glucksmann (PS-PP)
--   S4  Philippe seul (centre), Faure (PS-PP)
--   S5  Attal seul (centre), Faure (PS-PP)
--   S6  champ élargi : Ruffin, Glucksmann, Attal, Philippe, Villepin, Lisnard
--   S7  Philippe seul (centre), Royal (PS-PP)
--   S8  Philippe seul (centre), Guedj (PS-PP)
--   S9  Philippe seul (centre), Maurel (PS-PP)
--   S10 Philippe seul (centre), Hollande (PS-PP)
--
-- Règle du 27 septembre appliquée partout où deux figures du bloc Centre
-- sont candidates dans le MÊME scénario (S1 et S6, Attal+Philippe) : seul
-- le score le plus élevé (Philippe) est saisi, l'autre omis.
--
-- Bloc 'gauche' : seul Glucksmann y est saisi (S1, S2, S3, S6), conformément
-- à la convention déjà en usage dans cette base (voir correctif du
-- 27 septembre) — Faure, Royal, Guedj, Maurel et Hollande, qui remplacent
-- Glucksmann comme candidat PS-PP dans S4/S5/S7/S8/S9/S10, sont rangés
-- dans 'autres', comme Faure et Hollande l'étaient déjà pour les sondages
-- précédents. Incohérence d'étiquetage déjà signalée, conservée pour la
-- cohérence de la série.
--
-- Bloc 'autres' : agrégat volontaire de petits candidats distincts par
-- hypothèse (comportement assumé du bloc, voir METHODOLOGY.md).
--
-- Échantillon : 1 393 personnes inscrites sur les listes électorales,
-- issues d'un échantillon représentatif de 1 527 personnes de 18 ans et
-- plus. Un seul sample_size utilisé pour les 10 hypothèses (même
-- simplification que pour les sondages Cluster17 déjà en base : effectifs
-- utiles différents par scénario non détaillés dans la source).
--
-- Recherche de sondages plus récents (depuis le 8 octobre 2026, date de
-- dernière vérification) : AUCUN nouveau sondage d'intentions de vote au
-- 1er tour correctement sourcé trouvé. Vérifiés et écartés comme n'étant
-- PAS des intentions de vote 1er tour : Toluna/CommStrat-L'Opinion
-- "Opinion des Français" vague 7 (baromètre de potentiel électoral,
-- publié 7-8 oct., explicitement écrit par l'institut comme n'étant "pas
-- une intention de vote") ; Toluna "Les Français et le système de santé"
-- (29 sept., hors-sujet) ; Toluna "Les Français et les débats de la
-- primaire sociale-démocrate" (8-9 oct., sur la primaire PS, pas le 1er
-- tour). Agrégateurs tiers consultés (sondax.fr, elections2027.com,
-- sondage-presidentielle.fr, votons-2027.fr, electionpresidentielle2027.com)
-- : tous plafonnent au 29 septembre 2026, rien de postérieur au 8 octobre.
-- Registre MieuxVoter (GitHub) : la PR la plus récente trouvée (#238,
-- fusionnée le 2 octobre) porte sur CE MÊME sondage Ifop du 30 septembre,
-- pas sur un sondage plus récent.

begin;

insert into pollsters (name, notes) values ('IFOP', null) on conflict (name) do nothing;

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'IFOP'),
  'LCI / Le Figaro / Sud Radio', '2026-09-25', '2026-09-29', '2026-09-30', 1393, 'raw',
  'https://www.ifopgroup.com/wp-content/uploads/2026/10/122802-resultats-densemble-1.pdf',
  'Baromètre de l''élection présidentielle, vague 6 (focus primaire PS-PP). 10 hypothèses testées (S1 à S10), chacune vérifiée à somme = 100 % dans le PDF institut. Précédemment écarté (notice commission des sondages 10284) faute de source primaire ; résolu le 11 octobre 2026 via le PDF ifopgroup.com. S1 et S6 : Attal, co-candidat secondaire du centre face à Philippe dans le même scénario, non saisi (règle du 27 septembre). Royal/Guedj/Maurel/Hollande/Faure (remplaçant Glucksmann comme candidat PS-PP selon le scénario) rangés dans Autres, par cohérence avec les saisies précédentes.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
-- RN (Le Pen, les 10 hypothèses)
select id, 'rn', 'Le Pen (S1)', 32.0, 32.0, 32.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S2)', 33.0, 33.0, 33.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S3)', 34.0, 34.0, 34.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S4)', 35.0, 35.0, 35.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S5)', 36.0, 36.0, 36.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S6)', 31.0, 31.0, 31.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S7)', 35.0, 35.0, 35.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S8)', 35.0, 35.0, 35.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S9)', 35.0, 35.0, 35.0 from polls where source_url like '%122802-resultats%'
union all select id, 'rn', 'Le Pen (S10)', 34.0, 34.0, 34.0 from polls where source_url like '%122802-resultats%'
-- Centre (figure principale par hypothèse)
union all select id, 'centre', 'Philippe (S1)', 16.0, 16.0, 16.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S2)', 21.0, 21.0, 21.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Attal (S3)', 15.0, 15.0, 15.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S4)', 23.0, 23.0, 23.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Attal (S5)', 17.0, 17.0, 17.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S6)', 15.0, 15.0, 15.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S7)', 24.0, 24.0, 24.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S8)', 23.0, 23.0, 23.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S9)', 23.0, 23.0, 23.0 from polls where source_url like '%122802-resultats%'
union all select id, 'centre', 'Philippe (S10)', 22.0, 22.0, 22.0 from polls where source_url like '%122802-resultats%'
-- LFI (Mélenchon)
union all select id, 'lfi', 'Mélenchon (S1)', 15.0, 15.0, 15.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S2)', 16.0, 16.0, 16.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S3)', 15.0, 15.0, 15.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S4)', 16.0, 16.0, 16.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S5)', 17.0, 17.0, 17.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S6)', 14.0, 14.0, 14.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S7)', 15.0, 15.0, 15.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S8)', 17.0, 17.0, 17.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S9)', 17.0, 17.0, 17.0 from polls where source_url like '%122802-resultats%'
union all select id, 'lfi', 'Mélenchon (S10)', 16.0, 16.0, 16.0 from polls where source_url like '%122802-resultats%'
-- Gauche mod. / écolo (Glucksmann, présent seulement en S1, S2, S3, S6)
union all select id, 'gauche', 'Glucksmann (S1)', 11.0, 11.0, 11.0 from polls where source_url like '%122802-resultats%'
union all select id, 'gauche', 'Glucksmann (S2)', 11.0, 11.0, 11.0 from polls where source_url like '%122802-resultats%'
union all select id, 'gauche', 'Glucksmann (S3)', 13.0, 13.0, 13.0 from polls where source_url like '%122802-resultats%'
union all select id, 'gauche', 'Glucksmann (S6)', 9.0, 9.0, 9.0 from polls where source_url like '%122802-resultats%'
-- Droite classique (Retailleau)
union all select id, 'droite', 'Retailleau (S1)', 7.0, 7.0, 7.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S2)', 8.0, 8.0, 8.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S3)', 10.0, 10.0, 10.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S4)', 8.0, 8.0, 8.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S5)', 11.0, 11.0, 11.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S6)', 5.0, 5.0, 5.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S7)', 8.0, 8.0, 8.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S8)', 8.0, 8.0, 8.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S9)', 9.0, 9.0, 9.0 from polls where source_url like '%122802-resultats%'
union all select id, 'droite', 'Retailleau (S10)', 7.0, 7.0, 7.0 from polls where source_url like '%122802-resultats%'
-- Autres (agrégat de petits candidats distincts par hypothèse, + figures PS-PP remplaçant Glucksmann)
union all select id, 'autres', 'Arthaud (S1)', 0.5, 0.5, 0.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S1)', 2.5, 2.5, 2.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S1)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S1)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S1)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S2)', 0.5, 0.5, 0.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S2)', 2.5, 2.5, 2.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S2)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S2)', 1.5, 1.5, 1.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S2)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S3)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S3)', 2.5, 2.5, 2.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S3)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S3)', 2.0, 2.0, 2.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S3)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S4)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S4)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S4)', 5.0, 5.0, 5.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Faure (S4)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S4)', 1.5, 1.5, 1.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S4)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S5)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S5)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S5)', 5.5, 5.5, 5.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Faure (S5)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S5)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S5)', 4.5, 4.5, 4.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S6)', 0.5, 0.5, 0.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S6)', 2.0, 2.0, 2.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S6)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Ruffin (S6)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Villepin (S6)', 2.0, 2.0, 2.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Lisnard (S6)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S6)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S6)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S7)', 0.5, 0.5, 0.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S7)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S7)', 6.0, 6.0, 6.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Royal (S7)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S7)', 1.5, 1.5, 1.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S7)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S8)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S8)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S8)', 5.5, 5.5, 5.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Guedj (S8)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S8)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S8)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S9)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S9)', 3.5, 3.5, 3.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S9)', 6.0, 6.0, 6.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Maurel (S9)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S9)', 1.5, 1.5, 1.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S9)', 3.0, 3.0, 3.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Arthaud (S10)', 0.5, 0.5, 0.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Roussel (S10)', 2.5, 2.5, 2.5 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Tondelier (S10)', 5.0, 5.0, 5.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Hollande (S10)', 8.0, 8.0, 8.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Dupont-Aignan (S10)', 1.0, 1.0, 1.0 from polls where source_url like '%122802-resultats%'
union all select id, 'autres', 'Zemmour (S10)', 4.0, 4.0, 4.0 from polls where source_url like '%122802-resultats%';

commit;
