with src as (
  select * from {{ source('eurovision','BOOKMAKERS') }}
),
typed as (
  select
    cast(year as integer)      as year,
    lower(round)               as round,        -- 'final' | 'semi-final-1' | 'semi-final-2'
    upper(country)             as country_id,
    bookmaker,
    try_to_decimal(odds, 18,6) as odds_decimal
  from src
),
clean as (
  select * from typed
  where odds_decimal is not null and odds_decimal > 0
)
select
  *,
  1/odds_decimal              as implied_prob
from clean
