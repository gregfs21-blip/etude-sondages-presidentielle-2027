-- Vue d'agrégation : une ligne par (sondage, bloc), prête à être consommée
-- par le filtre de Kalman côté Node. Toute la logique "SQL-native" (dates,
-- moyennes, regroupement des hypothèses multiples) vit ici ; le calcul de
-- variance d'observation et la récursion de Kalman restent côté code (voir
-- lib/variance.mjs et lib/kalman.mjs) car ils ne sont pas naturellement
-- exprimables en SQL ensembliste.

begin;

drop view if exists v_poll_bloc_observations;

create view v_poll_bloc_observations as
select
  p.id                                              as poll_id,
  b.id                                               as bloc_id,
  b.label                                            as bloc_label,
  b.sort_order                                       as bloc_sort_order,
  pl.name                                            as pollster_name,
  p.sponsor,
  p.source_url,
  p.poll_type,
  p.sample_size,
  p.field_start,
  p.field_end,
  p.published_date,
  -- Date d'observation retenue pour le filtre : milieu de la période de
  -- terrain quand elle est connue (c'est le moment où l'opinion a
  -- réellement été mesurée), sinon date de publication moins 3 jours
  -- (délai médian terrain→publication observé sur nos sondages sourcés).
  coalesce(
    p.field_start + ((p.field_end - p.field_start) / 2),
    p.published_date - interval '3 days'
  )::date                                            as obs_date,
  count(*)                                           as n_hypotheses,
  string_agg(distinct r.candidate_label, ' / ' order by r.candidate_label) as candidate_labels,
  min(r.low_pct)                                     as low_pct,
  max(r.high_pct)                                    as high_pct,
  -- Estimation ponctuelle : moyenne du point publié quand il existe,
  -- sinon du milieu de la fourchette de CHAQUE hypothèse (pas du milieu
  -- de la fourchette globale, qui serait tiré par les hypothèses
  -- extrêmes) — d'où la moyenne des midpoints individuels ici, calculée
  -- avant l'agrégation par bloc.
  avg(coalesce(r.point_pct, (r.low_pct + r.high_pct) / 2.0))::numeric(5,2) as point_pct_avg
from poll_results r
join polls p     on p.id = r.poll_id
join pollsters pl on pl.id = p.pollster_id
join blocs b     on b.id = r.bloc_id
group by p.id, b.id, b.label, b.sort_order, pl.name, p.sponsor, p.source_url,
         p.poll_type, p.sample_size, p.field_start, p.field_end, p.published_date;

commit;
