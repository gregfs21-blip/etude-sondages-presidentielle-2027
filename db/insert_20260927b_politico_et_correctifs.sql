-- 27 septembre 2026 (2e passe, même jour). Deux choses :
--
-- 1. CORRECTIF d'encodage. La vue v_poll_bloc_observations fait la MOYENNE
--    des lignes d'un même (sondage, bloc) : c'est voulu pour des hypothèses
--    ALTERNATIVES (Le Pen OU Bardella), mais faux quand deux figures du même
--    bloc sont candidates dans le MÊME scénario. Trois lignes de ce type
--    avaient été saisies et tiraient artificiellement le bloc vers le bas :
--      - Cluster17/Le Point, scénario 3 : Ruffin (4 %) moyenné avec
--        Mélenchon dans LFI (bloc LFI observé à 14,25 % au lieu de 17,7 %) —
--        Ruffin n'est d'ailleurs plus LFI, classement discutable en soi ;
--      - Cluster17/Le Point, scénario 3 : Lisnard (4 %) moyenné avec
--        Retailleau dans Droite ;
--      - OpinionWay/CNews, scénario Attal+Philippe : Attal (7 %) moyenné
--        avec Philippe dans Centre.
--    Règle retenue désormais (cohérente avec les sondages saisis en
--    fourchettes, où seule la figure principale est enregistrée) : UNE
--    figure principale par bloc et par scénario ; les co-candidats
--    secondaires du même bloc ne sont pas saisis.
--
-- 2. AJOUT du sondage Cluster17 pour Politico (terrain 15-16 sept., publié
--    24 sept. 2026), manqué lors de la passe précédente du même jour alors
--    qu'il figurait au registre de la commission des sondages (réf. 10273).
--    Chiffres relevés dans le PDF de l'institut (chaque hypothèse somme à
--    100 %, vérifié).
--
-- Toujours écartés faute de chiffres vérifiables : Odoxa/Le Figaro 16 sept.
-- (réf. 10267), OpinionWay PrésiTrack/Les Echos 10 sept. (seul Le Pen 34 %
-- publié en clair), OpinionWay 15 sept. (réf. 10264), CSA/CNews 18 sept.
-- (réf. 10268, a priori une question isolée), IFOP/Paris Match 22 sept.

begin;

delete from poll_results
where candidate_label in ('Ruffin (scénario 3)', 'Lisnard (scénario 3)')
  and poll_id = (select id from polls where source_url like '%C17_Le_Point%');

delete from poll_results
where candidate_label = 'Attal (scénario Attal+Philippe)'
  and poll_id = (select id from polls where source_url like '%1055162%');

insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes)
values (
  (select id from pollsters where name = 'Cluster17'),
  'Politico', '2026-09-15', '2026-09-16', '2026-09-24', 1943, 'raw',
  'https://cluster17.com/wp-content/uploads/2026/09/Intentions-de-vote-P27-Politico-Septembre-26.pdf',
  '3 hypothèses. H1 Philippe, H2 Attal, H3 Hollande à la place de Glucksmann et Lisnard à la place de Zemmour. Lisnard (5 %, H3) non saisi : co-candidat secondaire du bloc Droite (règle : une figure principale par bloc et par scénario). Hollande rangé dans Autres, par cohérence avec les saisies précédentes.'
);

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'rn', 'Le Pen (H1)', 31.0, 31.0, 31.0 from polls where source_url like '%P27-Politico%'
union all select id, 'rn', 'Le Pen (H2)', 31.0, 31.0, 31.0 from polls where source_url like '%P27-Politico%'
union all select id, 'rn', 'Le Pen (H3)', 30.0, 30.0, 30.0 from polls where source_url like '%P27-Politico%'
union all select id, 'centre', 'Philippe (H1)', 19.0, 19.0, 19.0 from polls where source_url like '%P27-Politico%'
union all select id, 'centre', 'Attal (H2)', 13.5, 13.5, 13.5 from polls where source_url like '%P27-Politico%'
union all select id, 'centre', 'Philippe (H3)', 19.5, 19.5, 19.5 from polls where source_url like '%P27-Politico%'
union all select id, 'lfi', 'Mélenchon (H1)', 19.0, 19.0, 19.0 from polls where source_url like '%P27-Politico%'
union all select id, 'lfi', 'Mélenchon (H2)', 20.0, 20.0, 20.0 from polls where source_url like '%P27-Politico%'
union all select id, 'lfi', 'Mélenchon (H3)', 19.5, 19.5, 19.5 from polls where source_url like '%P27-Politico%'
union all select id, 'gauche', 'Glucksmann (H1)', 12.0, 12.0, 12.0 from polls where source_url like '%P27-Politico%'
union all select id, 'gauche', 'Glucksmann (H2)', 14.0, 14.0, 14.0 from polls where source_url like '%P27-Politico%'
union all select id, 'droite', 'Retailleau (H1)', 7.5, 7.5, 7.5 from polls where source_url like '%P27-Politico%'
union all select id, 'droite', 'Retailleau (H2)', 9.5, 9.5, 9.5 from polls where source_url like '%P27-Politico%'
union all select id, 'droite', 'Retailleau (H3)', 7.5, 7.5, 7.5 from polls where source_url like '%P27-Politico%'
union all select id, 'autres', 'Hollande (H3)', 7.5, 7.5, 7.5 from polls where source_url like '%P27-Politico%'
union all select id, 'autres', 'Zemmour', 3.5, 3.5, 3.5 from polls where source_url like '%P27-Politico%'
union all select id, 'autres', 'Dupont-Aignan', 3.0, 4.0, null::numeric from polls where source_url like '%P27-Politico%'
union all select id, 'autres', 'Roussel', 2.0, 3.0, null::numeric from polls where source_url like '%P27-Politico%'
union all select id, 'autres', 'Tondelier', 2.5, 3.0, null::numeric from polls where source_url like '%P27-Politico%';

commit;
