with v as (
  select *
  from {{ ref('stg_eurovision__votes') }}
  where round = 'final'
),
per_year_baseline as (
  select
    year,
    to_country_id,
    avg(total_points)        as avg_to_b,
    stddev_pop(total_points) as sd_to_b
  from v
  group by year, to_country_id
),
pair_year as (
  select
    v.year,
    v.from_country_id,
    v.to_country_id,
    sum(v.total_points) as actual_points,
    b.avg_to_b,
    b.sd_to_b
  from v
  join per_year_baseline b
    on v.year = b.year
   and v.to_country_id = b.to_country_id
  group by
    v.year,
    v.from_country_id,
    v.to_country_id,
    b.avg_to_b,
    b.sd_to_b
),
z as (
  select
    year,
    from_country_id,
    to_country_id,
    (actual_points - avg_to_b) / nullif(sd_to_b, 0) as affinity_z
  from pair_year
  where sd_to_b is not null and sd_to_b <> 0
),
agg as (
  select
    from_country_id,
    to_country_id,
    count(*)        as years_observed,
    avg(affinity_z) as affinity_z_avg
  from z
  group by from_country_id, to_country_id
  having count(*) >= 3
),
names as (select * from {{ ref('stg_eurovision__countries') }})
select
  a.from_country_id,
  nf.country_name as from_country_name,
  nf.region       as from_region,
  a.to_country_id,
  nt.country_name as to_country_name,
  nt.region       as to_region,
  a.years_observed,
  a.affinity_z_avg
from agg a
left join names nf on a.from_country_id = nf.country_id
left join names nt on a.to_country_id   = nt.country_id
order by affinity_z_avg desc
