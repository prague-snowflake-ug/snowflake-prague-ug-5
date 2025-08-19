-- macros/winner_country.sql
{% macro winner_country(year) -%}
(
  select country_name
  from {{ ref('mart_results_overview') }}
  where year = {{ year }} and final_total_points is not null
  order by final_total_points desc, country_id
  limit 1
)
{%- endmacro %}