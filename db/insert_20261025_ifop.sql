-- Sondage ajouté le 25 octobre 2026 (exécution automatique planifiée).
-- Ifop-Fiducial pour LCI, Le Figaro et Sud Radio, "Baromètre de l'élection
-- présidentielle, vague 7", terrain du 17 octobre (20h) au 19 octobre 2026,
-- fiche technique FD N°122853, notice commission des sondages 10327
-- (déposée/datée "octobre 2026", articles de presse datés du 20-21 oct.).
--
-- CE SONDAGE RÉSOUT UNE PISTE LAISSÉE OUVERTE LE 18 OCTOBRE : la session du
-- 18 oct. avait repéré via economiematin.fr un "IFOP-Fiducial, terrain
-- 12-14 octobre 2026, n=1390", trouvé non vérifiable (pas de PDF institut
-- localisé, chiffres secondaires ambigus/contradictoires) et donc PAS
-- ajouté. Cette session a recherché activement ce sondage et n'a trouvé
-- AUCUNE fiche à la commission des sondages correspondant à ces paramètres
-- (terrain 12-14 oct., n=1390) ; en revanche, la vague 7 ci-dessous (terrain
-- réel 17-19 oct., n=1928 inscrits, publiée le 20 oct.) est la seule étude
-- Ifop-Fiducial/LCI-Figaro-Sud Radio déposée sur la période, avec PDF
-- institut directement vérifiable. Hypothèse retenue : l'article
-- economiematin.fr du 18 oct. décrivait, de façon confuse, une version
-- préliminaire ou mal datée de CETTE MÊME vague 7 — mais faute de certitude,
-- les paramètres "12-14 oct./n=1390" ne sont PAS repris ici : seuls les
-- paramètres vérifiés sur le PDF institut (terrain 17-19 oct., n=1928) sont
-- saisis.
--
-- PDF institut (Commission des sondages, dépôt officiel obligatoire) :
--   https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10327-pres-barometre-election-v7-ifop-20-octobre.pdf
-- Vérifié directement par WebFetch depuis cette session (pas seulement via
-- un sous-agent) : 8 hypothèses testées (S1 à S8), chacune vérifiée à
-- somme = 100 % dans le document.
--
-- Légende des hypothèses (telle que documentée par l'institut) :
--   S1  Philippe + Attal (centre divisé), Glucksmann (PS-PP)
--   S2  Philippe seul (centre), Glucksmann (PS-PP)
--   S3  Attal seul (centre), Glucksmann (PS-PP)
--   S4  Philippe seul (centre), Glucksmann (PS-PP) — Roussel/Tondelier non testés
--   S5  Philippe + Attal (centre divisé), Hollande (PS-PP, Glucksmann absent)
--   S6  champ élargi : Ruffin, Villepin, Lisnard ; Philippe + Attal (centre)
--   S7  Lisnard seul à droite (Retailleau absent) ; Philippe + Attal (centre)
--   S8  Ruffin + Polony ; Philippe + Attal (centre)
--
-- Règle du 27 septembre appliquée partout où Philippe ET Attal sont tous
-- deux candidats dans le MÊME scénario (S1, S5, S6, S7, S8) : seul le score
-- le plus élevé est saisi, l'autre omis. Dans ces 5 scénarios, Philippe est
-- systématiquement supérieur à Attal et donc retenu ; Attal n'est retenu
-- seul (S3) que lorsque Philippe n'est pas testé dans le scénario.
--
-- Bloc 'gauche' : seul Glucksmann y est saisi (S1-S4, S6-S8), conformément
-- à la convention déjà en usage dans cette base — Hollande, qui remplace
-- Glucksmann comme candidat PS-PP alternatif en S5, va dans 'autres', par
-- cohérence avec les saisies précédentes (IFOP du 11 oct., Toluna vague 7
-- du 18 oct., etc.).
--
-- Bloc 'droite' : seul Retailleau y est saisi (S1-S6, S8). En S7, Retailleau
-- n'est PAS testé (seul Lisnard, 7 %, candidat à droite) : conformément à
-- la convention du bloc ("seul Retailleau (LR)", voir db/schema.sql et les
-- saisies IFOP du 11 oct. où Villepin/Lisnard allaient déjà dans 'autres'
-- même en présence de Retailleau), AUCUNE ligne 'droite' n'est saisie pour
-- S7 — Lisnard y est rangé dans 'autres', comme Villepin et Lisnard le sont
-- déjà en S6.
--
-- Bloc 'autres' : agrégat volontaire de petits candidats distincts par
-- hypothèse (Arthaud, Roussel, Tondelier, Dupont-Aignan, Zemmour, Ruffin,
-- Villepin, Lisnard, Polony, et Hollande en S5), comportement assumé du
-- bloc (voir METHODOLOGY.md).
--
-- Échantillon : 1 928 personnes inscrites sur les listes électorales,
-- extraites d'un échantillon représentatif de 2 081 personnes de 18 ans et
-- plus. Un seul sample_size utilisé pour les 8 hypothèses (même
-- simplification que pour les sondages IFOP/Cluster17 précédents : la
-- notice ne publie que le nombre de personnes ayant exprimé un choix par
-- scénario, 1360 à 1463, pas un échantillon représentatif par scénario).
--
-- Aucun autre sondage de premier tour correctement sourcé n'a été trouvé
-- publié entre le 18 et le 25 octobre 2026 (recherche ciblée Ifop, Elabe,
-- Ipsos, Odoxa, OpinionWay, Harris Interactive/Toluna, BVA, CSA, Cluster17,
-- Verian — voir claude/suivi-sondages-2027.md pour le détail des notices
-- examinées et écartées).

begin;

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'IFOP'),
  'LCI / Le Figaro / Sud Radio', '2026-10-17', '2026-10-19', '2026-10-20', 1928, 'raw',
  'https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10327-pres-barometre-election-v7-ifop-20-octobre.pdf',
  'Baromètre de l''élection présidentielle, vague 7 (fiche FD N°122853, notice 10327). 8 hypothèses testées (S1 à S8), chacune vérifiée à somme = 100 % dans le PDF institut (dépôt officiel Commission des sondages), vérifié directement par cette session. Résout la piste laissée ouverte le 18 octobre (sondage "12-14 oct./n=1390" cité par economiematin.fr, non confirmé par aucune fiche commission des sondages correspondante — voir claude/suivi-sondages-2027.md) : seuls les paramètres vérifiés sur CE PDF (terrain 17-19 oct., n=1928) sont saisis. S1/S5/S6/S7/S8 : Attal, co-candidat secondaire du centre face à Philippe dans le même scénario, non saisi (règle du 27 septembre). Hollande (remplaçant Glucksmann comme candidat PS-PP en S5) et Lisnard (seul candidat de droite testé en S7, Retailleau absent de ce scénario) rangés dans Autres, par cohérence avec les saisies précédentes.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
-- RN (Le Pen, les 8 hypothèses — Bardella non testé dans cette vague)
select id, 'rn', 'Le Pen (S1)', 36.0, 36.0, 36.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S2)', 36.0, 36.0, 36.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S3)', 38.0, 38.0, 38.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S4)', 37.0, 37.0, 37.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S5)', 38.0, 38.0, 38.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S6)', 34.0, 34.0, 34.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S7)', 36.0, 36.0, 36.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'rn', 'Le Pen (S8)', 35.0, 35.0, 35.0 from polls where source_url like '%10327-pres-barometre%'
-- Centre (figure principale par hypothèse : Philippe si présent et >= Attal, sinon Attal seul)
union all select id, 'centre', 'Philippe (S1)', 12.0, 12.0, 12.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S2)', 15.0, 15.0, 15.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Attal (S3)', 13.0, 13.0, 13.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S4)', 16.0, 16.0, 16.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S5)', 14.0, 14.0, 14.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S6)', 12.0, 12.0, 12.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S7)', 13.0, 13.0, 13.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'centre', 'Philippe (S8)', 12.0, 12.0, 12.0 from polls where source_url like '%10327-pres-barometre%'
-- LFI (Mélenchon)
union all select id, 'lfi', 'Mélenchon (S1)', 16.5, 16.5, 16.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S2)', 16.5, 16.5, 16.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S3)', 16.0, 16.0, 16.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S4)', 18.0, 18.0, 18.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S5)', 20.0, 20.0, 20.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S6)', 15.0, 15.0, 15.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S7)', 15.5, 15.5, 15.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'lfi', 'Mélenchon (S8)', 15.0, 15.0, 15.0 from polls where source_url like '%10327-pres-barometre%'
-- Gauche mod. / écolo (Glucksmann seulement ; absent en S5, remplacé par Hollande -> autres)
union all select id, 'gauche', 'Glucksmann (S1)', 13.5, 13.5, 13.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S2)', 14.0, 14.0, 14.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S3)', 16.0, 16.0, 16.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S4)', 16.0, 16.0, 16.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S6)', 12.0, 12.0, 12.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S7)', 13.0, 13.0, 13.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'gauche', 'Glucksmann (S8)', 12.0, 12.0, 12.0 from polls where source_url like '%10327-pres-barometre%'
-- Droite classique (Retailleau seul ; absent en S7, remplacé par Lisnard seul -> autres)
union all select id, 'droite', 'Retailleau (S1)', 5.0, 5.0, 5.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S2)', 7.5, 7.5, 7.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S3)', 7.0, 7.0, 7.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S4)', 6.5, 6.5, 6.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S5)', 6.0, 6.0, 6.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S6)', 5.5, 5.5, 5.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'droite', 'Retailleau (S8)', 6.0, 6.0, 6.0 from polls where source_url like '%10327-pres-barometre%'
-- Autres (agrégat de petits candidats distincts par hypothèse + figures PS-PP/droite alternatives)
union all select id, 'autres', 'Arthaud (S1)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S1)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S1)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S1)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S1)', 3.5, 3.5, 3.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S2)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S2)', 2.5, 2.5, 2.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S2)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S2)', 1.5, 1.5, 1.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S2)', 3.5, 3.5, 3.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S3)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S3)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S3)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S3)', 1.5, 1.5, 1.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S3)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S4)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S4)', 2.5, 2.5, 2.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S4)', 3.5, 3.5, 3.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S5)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S5)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S5)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Hollande (S5)', 10.0, 10.0, 10.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S6)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S6)', 2.5, 2.5, 2.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Ruffin (S6)', 1.5, 1.5, 1.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Villepin (S6)', 1.5, 1.5, 1.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Lisnard (S6)', 5.5, 5.5, 5.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S6)', 1.5, 1.5, 1.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S6)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S7)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S7)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S7)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Lisnard (S7)', 7.0, 7.0, 7.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S7)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S7)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Arthaud (S8)', 0.5, 0.5, 0.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Roussel (S8)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Tondelier (S8)', 3.0, 3.0, 3.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Ruffin (S8)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Dupont-Aignan (S8)', 2.0, 2.0, 2.0 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Zemmour (S8)', 3.5, 3.5, 3.5 from polls where source_url like '%10327-pres-barometre%'
union all select id, 'autres', 'Polony (S8)', 1.0, 1.0, 1.0 from polls where source_url like '%10327-pres-barometre%';

commit;
