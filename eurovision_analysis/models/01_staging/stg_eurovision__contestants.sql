/* 
Grain: 1 row per (year, country)
Purpose: Type, clean, and enrich contestant/entry attributes (semifinal/final points, running orders).
Key Derivations: 
  - qualified_to_final (boolean)
  - jury_minus_televote_final = final_jury_points - final_televoting_points
*/


with src as (
  select * from {{ source('eurovision','CONTESTANTS') }}
)
select
  try_to_number(year)                         as year,
  upper(country)                                as country_id,
  performer,
  song,
  composers,
  lyricists,
  nullif(lyrics, '')                            as lyrics,
  youtube_url,
  try_to_number(semifinal_number)             as semifinal_number,
  try_to_number(semifinal_running_order)      as semifinal_running_order,
  try_to_number(semifinal_jury_points)        as semifinal_jury_points,
  try_to_number(semifinal_televoting_points)  as semifinal_televoting_points,
  try_to_number(semifinal_total_points)       as semifinal_total_points,
  try_to_number(semifinal_place)              as semifinal_place,
  try_to_number(final_running_order)          as final_running_order,
  try_to_number(final_jury_points)            as final_jury_points,
  try_to_number(final_televoting_points)      as final_televoting_points,
  try_to_number(final_total_points)           as final_total_points,
  /* qualified if they have any final fields populated */
  (final_running_order is not null
    or final_total_points is not null)          as qualified_to_final,
  /* nice-to-have deriveds */
  (try_to_number(final_jury_points) - try_to_number(final_televoting_points)) as jury_minus_televote_final
from src
