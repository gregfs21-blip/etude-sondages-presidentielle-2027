-- Sondage ajouté le 1er novembre 2026 (exécution automatique planifiée).
-- Cluster17 pour Politico, "Intentions de vote premier tour, présidentielle
-- 2027", terrain 19-22 octobre 2026, notice commission des sondages 10339
-- ("Pres IV CLUSTER17 Politico"), déposée/publiée le 26 octobre 2026.
--
-- PDF institut (Commission des sondages, dépôt officiel obligatoire),
-- vérifié directement par WebFetch depuis cette session (pas seulement via
-- un sous-agent de recherche, conformément à la règle du runbook) :
--   https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10339-pres-iv-cluster17-politico-26-octobre.pdf
-- 3 hypothèses testées (H1 à H3), chacune vérifiée à somme = 100 % dans le
-- document (scores publiés ; les scores redressés arrondis à 99,9% pour H1
-- sont un artefact d'arrondi documenté par l'institut lui-même, sans
-- consequence sur les scores publiés utilisés ici).
--
-- Échantillon : 2 817 personnes inscrites sur les listes électorales ;
-- effectifs utiles après pondération différents par hypothèse (1920/1889/
-- 1917) mais non détaillés assez finement pour une saisie par hypothèse :
-- un seul sample_size utilisé pour les 3 hypothèses (même simplification
-- que pour les sondages Cluster17/IFOP précédents déjà en base).
--
-- Légende des hypothèses (telle que documentée par l'institut) :
--   H1  Philippe seul (centre), Le Pen (RN), Glucksmann (gauche)
--   H2  Attal seul (centre), Le Pen (RN), Glucksmann (gauche)
--   H3  Philippe seul (centre), Le Pen (RN), Lisnard (droite, co-candidat
--       de Retailleau dans le même scénario), Hollande (PS-PP alternatif
--       à Glucksmann, absent de ce scénario)
--
-- Bardella n'est testé dans aucune des 3 hypothèses (seule Le Pen est
-- testée côté RN dans ce sondage) : aucun ajustement nécessaire, une seule
-- figure RN par hypothèse de toute façon.
--
-- Bloc 'gauche' : seul Glucksmann y est saisi (H1, H2), conformément à la
-- convention déjà en usage dans cette base — Hollande, qui remplace
-- Glucksmann comme candidat PS-PP alternatif en H3 (Glucksmann absent de ce
-- scénario), va dans 'autres', par cohérence avec les saisies précédentes
-- (IFOP du 11 et du 25 oct., Toluna vague 7 du 18 oct., etc.).
--
-- Bloc 'droite' : seul Retailleau y est saisi (H1, H2, H3 — présent dans
-- les 3 hypothèses, contrairement à certains sondages précédents où il
-- était parfois absent). En H3, Lisnard (8,0 %) est un CO-CANDIDAT du même
-- bloc dans le MÊME scénario que Retailleau (7,0 %) : conformément à la
-- convention du bloc ("seul Retailleau (LR)", voir db/schema.sql et les
-- saisies IFOP du 11 et du 25 oct. où Villepin/Lisnard allaient déjà dans
-- 'autres' même en présence de Retailleau), Lisnard est rangé dans
-- 'autres', PAS dans 'droite' (règle du 27 septembre : une figure
-- principale par bloc et par scénario, ici Retailleau reste la figure
-- 'droite' de référence pour la cohérence de la série).
--
-- Bloc 'autres' : agrégat volontaire de petits candidats distincts par
-- hypothèse (Dupont-Aignan, Zemmour, Roussel, Tondelier, Arthaud pour les
-- 3 hypothèses, + Lisnard et Hollande en H3), comportement assumé du bloc
-- (voir METHODOLOGY.md).
--
-- Recherche menée pour la fenêtre du 25 octobre au 1er novembre 2026,
-- croisant le registre officiel commission-des-sondages.fr (tag
-- "Presidentielle-2027") et plusieurs agrégateurs tiers indépendants
-- (sondax.fr, epocinfo.fr, france-vote.fr) qui convergent sur le même
-- résultat : CE sondage Cluster17/Politico est le SEUL sondage d'intentions
-- de vote premier tour déposé dans cette fenêtre. Les autres dépôts de la
-- période (notices 10340 à 10345 : Odoxa x2, Elabe, Ipsos-BVA, Toluna
-- Harris Interactive) sont des baromètres thématiques (popularité,
-- confiance, mobilisations sociales, logement) sans volet intentions de
-- vote premier tour — écartés, pas des sondages électoraux au sens de ce
-- pipeline.

begin;

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Cluster17'),
  'Politico', '2026-10-19', '2026-10-22', '2026-10-26', 2817, 'raw',
  'https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10339-pres-iv-cluster17-politico-26-octobre.pdf',
  'Notice commission des sondages 10339 ("Pres IV CLUSTER17 Politico"), vérifiée directement par WebFetch depuis cette session. 3 hypothèses testées (H1 à H3), chacune vérifiée à somme = 100 % dans le PDF institut (scores publiés). Bardella non testé (seule Le Pen testée côté RN). H3 : Lisnard, co-candidat secondaire du bloc Droite face à Retailleau dans le même scénario, non saisi dans Droite (règle du 27 septembre) ; Hollande (remplaçant Glucksmann, absent de ce scénario) rangé dans Autres, par cohérence avec les saisies précédentes.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
-- RN (Le Pen, les 3 hypothèses — Bardella non testé)
select id, 'rn', 'Le Pen (H1)', 33.0, 33.0, 33.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'rn', 'Le Pen (H2)', 32.5, 32.5, 32.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'rn', 'Le Pen (H3)', 30.5, 30.5, 30.5 from polls where source_url like '%10339-pres-iv-cluster17%'
-- Centre (figure principale par hypothèse)
union all select id, 'centre', 'Philippe (H1)', 16.0, 16.0, 16.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'centre', 'Attal (H2)', 12.0, 12.0, 12.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'centre', 'Philippe (H3)', 17.0, 17.0, 17.0 from polls where source_url like '%10339-pres-iv-cluster17%'
-- LFI (Mélenchon)
union all select id, 'lfi', 'Mélenchon (H1)', 18.5, 18.5, 18.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'lfi', 'Mélenchon (H2)', 19.5, 19.5, 19.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'lfi', 'Mélenchon (H3)', 19.5, 19.5, 19.5 from polls where source_url like '%10339-pres-iv-cluster17%'
-- Gauche mod. / écolo (Glucksmann seulement ; absent en H3, remplacé par Hollande -> autres)
union all select id, 'gauche', 'Glucksmann (H1)', 13.0, 13.0, 13.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'gauche', 'Glucksmann (H2)', 14.0, 14.0, 14.0 from polls where source_url like '%10339-pres-iv-cluster17%'
-- Droite classique (Retailleau seul ; Lisnard en H3 rangé dans autres)
union all select id, 'droite', 'Retailleau (H1)', 8.0, 8.0, 8.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'droite', 'Retailleau (H2)', 10.0, 10.0, 10.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'droite', 'Retailleau (H3)', 7.0, 7.0, 7.0 from polls where source_url like '%10339-pres-iv-cluster17%'
-- Autres (agrégat de petits candidats distincts par hypothèse + Lisnard/Hollande en H3)
union all select id, 'autres', 'Dupont-Aignan (H1)', 3.0, 3.0, 3.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Zemmour (H1)', 4.0, 4.0, 4.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Roussel (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Tondelier (H1)', 2.0, 2.0, 2.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Arthaud (H1)', 0.5, 0.5, 0.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Dupont-Aignan (H2)', 3.5, 3.5, 3.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Zemmour (H2)', 4.0, 4.0, 4.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Roussel (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Tondelier (H2)', 2.0, 2.0, 2.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Arthaud (H2)', 0.5, 0.5, 0.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Lisnard (H3)', 8.0, 8.0, 8.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Hollande (H3)', 6.5, 6.5, 6.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Zemmour (H3)', 3.5, 3.5, 3.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Dupont-Aignan (H3)', 3.0, 3.0, 3.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Tondelier (H3)', 2.5, 2.5, 2.5 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Roussel (H3)', 2.0, 2.0, 2.0 from polls where source_url like '%10339-pres-iv-cluster17%'
union all select id, 'autres', 'Arthaud (H3)', 0.5, 0.5, 0.5 from polls where source_url like '%10339-pres-iv-cluster17%';

commit;
