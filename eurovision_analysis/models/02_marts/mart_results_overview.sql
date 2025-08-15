with c as (select * from {{ ref('stg_eurovision__contestants') }}),
k as (select * from {{ ref('stg_eurovision__countries') }}),
joined as (
  select
    c.year,
    c.country_id,
    k.country_name,
    k.region,
    c.performer,
    c.song,
    c.youtube_url,
    c.semifinal_number,
    c.semifinal_running_order,
    c.semifinal_jury_points,
    c.semifinal_televoting_points,
    c.semifinal_total_points,
    c.semifinal_place,
    c.final_running_order,
    c.final_jury_points,
    c.final_televoting_points,
    c.final_total_points,
    c.qualified_to_final,
    c.jury_minus_televote_final
  from c
  left join k using (country_id)
),
ranked as (
  select
    j.*,
    dense_rank() over (partition by year order by final_total_points desc nulls last) as final_rank,
    dense_rank() over (partition by year order by semifinal_total_points desc nulls last) as semifinal_rank
  from joined j
)
select * from ranked
