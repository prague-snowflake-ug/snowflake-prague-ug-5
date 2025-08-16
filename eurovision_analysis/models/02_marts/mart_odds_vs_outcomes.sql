/* 
Grain: 1 row per (year, country)
Purpose: Compare pre-final bookmaker probabilities to actual outcomes; quantify calibration/upsets.
Method:
  - Normalize per-year probabilities to sum ≈ 1
  - Compute implied_rank (by probability) vs final_rank; include rank_diff and winner_prob_error
Use Cases: Identify “upsets”, craft year-by-year narratives.
*/


-- Compare bookmaker implied probabilities (final) vs. actual outcomes
with odds as (
  select * from {{ ref('stg_eurovision__bookmakers') }}
  where round = 'final'
),
avg_prob as (
  -- average across bookmakers per (year, country)
  select
    year,
    country_id,
    avg(implied_prob) as avg_implied_prob
  from odds
  group by 1,2
),
norm as (
  -- normalize probs so they sum to ~1 per year
  select
    year, country_id,
    avg_implied_prob / nullif(sum(avg_implied_prob) over (partition by year), 0) as norm_implied_prob
  from avg_prob
),
res as (
  select
    r.year,
    r.country_id,
    r.country_name,
    r.region,
    r.performer,
    r.song,
    r.final_total_points,
    r.final_rank,
    n.norm_implied_prob
  from {{ ref('mart_results_overview') }} r
  left join norm n
    on r.year = n.year and r.country_id = n.country_id
  where r.final_total_points is not null
),
ranks as (
  select
    res.*,
    dense_rank() over (partition by year order by norm_implied_prob desc nulls last) as implied_rank,
    case when final_rank = 1 then 1 else 0 end as is_winner
  from res
),
calibration as (
  select
    year,
    country_id,
    country_name,
    region,
    performer,
    song,
    final_total_points,
    final_rank,
    implied_rank,
    norm_implied_prob,
    (implied_rank - final_rank) as rank_diff,
    (norm_implied_prob - case when is_winner=1 then 1.0 else 0.0 end) as winner_prob_error
  from ranks
)
select * from calibration
order by year desc, final_rank asc
