with src as (
  select * from {{ source('eurovision','VOTES') }}
),
norm as (
  select
    try_to_number(year)       as year,
    lower(round)                as round,          -- 'final', 'semi-final', 'semi-final-1', 'semi-final-2'
    upper(from_country)         as from_country_id,
    upper(to_country)           as to_country_id,
    try_to_number(total_points)   as total_points,
    try_to_number(televoting_points)  as televoting_points,
    try_to_number(jury_points)        as jury_points
  from src
)
select * from norm