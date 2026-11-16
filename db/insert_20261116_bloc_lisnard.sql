-- 16 novembre 2026 (décision de l'utilisateur) : création d'un bloc
-- « Lisnard » séparé.
--
-- Pourquoi. Jusqu'ici Lisnard était rangé dans 'autres' (règle « une figure
-- principale par bloc et par scénario », Retailleau étant la figure de
-- référence de 'droite'). Or il est passé de 3,5 % (IFOP, fin septembre) à
-- 10-12 % mi-novembre et dépasse Retailleau dans la plupart des scénarios où
-- les deux sont testés. Le laisser dans 'autres' (moyenne de petits
-- candidats) masquait le principal mouvement de la période et faisait
-- croire à une droite à ~6 %.
--
-- Ce que fait ce fichier :
--   1. crée le bloc 'lisnard' (inséré avant 'autres', qui passe en 7e) ;
--   2. renomme 'droite' en « LR (Retailleau) » : c'est ce qu'il mesure
--      réellement ;
--   3. reclasse dans 'lisnard' toutes les lignes Lisnard déjà saisies
--      (toutes dans 'autres') ;
--   4. réintègre les deux scores Lisnard supprimés ou non saisis en
--      septembre au nom de la règle « une figure par bloc », devenue sans
--      objet pour lui (valeurs relevées à l'époque dans les PDF Cluster17 et
--      consignées dans db/insert_20260927b_politico_et_correctifs.sql) :
--        - Cluster17 / Le Point, terrain 31 août-1er sept., scénario 3 : 4 %
--        - Cluster17 / Politico, terrain 15-16 sept., H3 : 5 %
--
-- Limite assumée : c'est une série par candidat, pas par bloc (écart au
-- principe de METHODOLOGY.md §2), et elle ne couvre que les scénarios où il
-- est testé. Quand il ne l'est pas, ses électeurs se répartissent ailleurs.
--
-- À partir de maintenant, tout nouveau score Lisnard se saisit dans
-- bloc_id = 'lisnard' (une ligne par hypothèse, comme les autres blocs).

begin;

update blocs set sort_order = 7 where id = 'autres';

insert into blocs (id, label, description, color_hex, color_hex_dark, sort_order) values
  ('lisnard', 'Lisnard', 'David Lisnard, suivi à part depuis le 16 nov. 2026 (avant : dans « Autres »)',
   '#8c564b', '#c49c94', 6);

update blocs
set label = 'LR (Retailleau)',
    description = 'Retailleau (LR) seul ; Lisnard a son propre bloc'
where id = 'droite';

update poll_results set bloc_id = 'lisnard'
where candidate_label ilike 'Lisnard%';

insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)
select id, 'lisnard', 'Lisnard (scénario 3)', 4.0, 4.0, 4.0
from polls where source_url like '%C17_Le_Point%'
union all
select id, 'lisnard', 'Lisnard (H3)', 5.0, 5.0, 5.0
from polls where source_url like '%P27-Politico%';

commit;
