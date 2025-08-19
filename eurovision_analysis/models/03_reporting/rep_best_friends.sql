select
  a.from_country_id,
  nf.country_name as from_country,
  a.to_country_id,
  nt.country_name as to_country,
  a.years_observed,
  round(a.affinity_z_avg, 2) as affinity
from {{ ref('mart_country_affinities') }} a
left join {{ ref('stg_eurovision__countries') }} nf on nf.country_id = a.from_country_id
left join {{ ref('stg_eurovision__countries') }} nt on nt.country_id = a.to_country_id
where a.years_observed >= 3
order by affinity desc
limit 20