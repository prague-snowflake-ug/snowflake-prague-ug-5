/* 
Grain: 1 row per (year, round, from_country_id → to_country_id, juror_letter)
Purpose: Unpivot juror A..E columns into tidy rows for micro jury analyses.
Derivations: juror_letter, juror_rank (int)
*/


with src as (
  select * from {{ source('eurovision','JURORS') }}
),
typed as (
  select
    try_to_number(year)  as year,
    lower(round)           as round,             -- 'final' | 'semi-final-1' | 'semi-final-2'
    upper(from_country)    as from_country_id,
    upper(to_country)      as to_country_id,
    A, B, C, D, E
  from src
),
unpvt as (
  select
    year, round, from_country_id, to_country_id,
    juror_letter, try_to_number(juror_rank) as juror_rank
  from typed
  unpivot (juror_rank for juror_letter in (A, B, C, D, E))
)
select * from unpvt
