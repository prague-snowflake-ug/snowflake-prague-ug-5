-- macros/print_winner_country.sql
{% macro print_winner_country(year) %}
  {% set sql %}
    select country_name
    from {{ ref('mart_results_overview') }}
    where year = {{ year }} and final_total_points is not null
    order by final_total_points desc, country_id
    limit 1
  {% endset %}

  {% if execute %}
    {% set t = run_query(sql) %}
    {% if t is not none and (t.rows | length) > 0 %}
      {% set country = t.columns[0].values()[0] %}
      {{ log(country, info=True) }}
      {{ return(country) }}
    {% else %}
      {{ log('No winner found for year ' ~ year, info=True) }}
      {{ return('') }}
    {% endif %}
  {% else %}
    {{ return('') }}
  {% endif %}
{% endmacro %}
