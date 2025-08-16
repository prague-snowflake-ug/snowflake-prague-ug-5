/* 
Grain: 1 row per country
Purpose: Normalize country identifiers for consistent joins and human-friendly output.
*/

with src as (
  select * from {{ source('eurovision','COUNTRIES') }}
)
select
  upper(country)            as country_id,
  initcap(country_name)     as country_name,
  initcap(region)           as region
from src
