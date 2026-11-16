-- Schéma : suivi des sondages présidentielle 2027
-- Postgres 14+. Idempotent (DROP ... IF EXISTS) pour pouvoir rejouer en dev.

begin;

drop table if exists poll_results cascade;
drop table if exists polls cascade;
drop table if exists blocs cascade;
drop table if exists pollsters cascade;

-- ---------------------------------------------------------------------
-- Instituts de sondage.
-- ---------------------------------------------------------------------
create table pollsters (
  id    serial primary key,
  name  text not null unique,
  notes text
);

-- ---------------------------------------------------------------------
-- "Blocs" = le niveau auquel on suit et on filtre les intentions de vote.
-- Volontairement plus grossier que "candidat", car la quasi-totalité des
-- candidatures ne sont pas déclarées : un institut teste "Le Pen" dans une
-- hypothèse et "Bardella" dans une autre, jamais les deux dans le même
-- scénario. Regrouper par bloc politique évite de traiter ces alternatives
-- comme des candidats distincts qui apparaîtraient/disparaîtraient d'un
-- sondage à l'autre.
-- ---------------------------------------------------------------------
create table blocs (
  id          text primary key,        -- slug stable, ex. 'rn'
  label       text not null,
  description text not null,           -- qui est regroupé sous ce bloc
  color_hex   text not null,           -- teinte catégorielle (palette validée CVD)
  color_hex_dark text not null,
  sort_order  int not null
);

-- ---------------------------------------------------------------------
-- Un sondage publié. `poll_type` distingue un sondage brut d'un institut
-- (une vague de terrain précise) d'une moyenne agrégée publiée par un
-- tiers (ex. moyenne glissante Elabe sur plusieurs mois) : cette dernière
-- ne doit JAMAIS être injectée comme observation brute dans le filtre de
-- Kalman — ce serait compter plusieurs fois les mêmes sondages et fausser
-- la variance. Elle reste stockée pour affichage/contrôle croisé.
-- ---------------------------------------------------------------------
create table polls (
  id            serial primary key,
  pollster_id   int not null references pollsters(id),
  sponsor       text,                  -- média commanditaire
  field_start   date,
  field_end     date,
  published_date date not null,
  sample_size   int,                   -- NULL si non publié
  poll_type     text not null default 'raw'
                  check (poll_type in ('raw', 'aggregate_reference')),
  source_url    text not null,
  notes         text,
  check (field_start is null or field_end is null or field_start <= field_end)
);

create index polls_published_date_idx on polls (published_date);

-- ---------------------------------------------------------------------
-- Un score, pour un bloc, dans une hypothèse de sondage donnée.
-- Plusieurs lignes peuvent partager (poll_id, bloc_id) quand l'institut a
-- testé plusieurs figures pour le même bloc (Philippe et Attal, tous deux
-- rattachés à 'centre', dans deux hypothèses distinctes du même sondage).
-- ---------------------------------------------------------------------
create table poll_results (
  id              serial primary key,
  poll_id         int not null references polls(id) on delete cascade,
  bloc_id         text not null references blocs(id),
  candidate_label text not null,       -- ex. 'Bardella', 'Le Pen', 'Philippe'
  low_pct         numeric(4,1) not null,
  high_pct        numeric(4,1) not null,
  point_pct       numeric(4,1),        -- estimation ponctuelle publiée, si connue
  check (low_pct <= high_pct),
  check (point_pct is null or (point_pct >= low_pct and point_pct <= high_pct))
);

create index poll_results_poll_idx on poll_results (poll_id);
create index poll_results_bloc_idx on poll_results (bloc_id);

commit;
