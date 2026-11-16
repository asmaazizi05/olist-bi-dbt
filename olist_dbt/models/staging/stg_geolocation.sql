-- 1 000 163 lignes brutes -> une ligne par préfixe de code postal
select
    cast(geolocation_zip_code_prefix as varchar) as zip_code_prefix,
    avg(geolocation_lat)                         as latitude,
    avg(geolocation_lng)                         as longitude,
    mode(lower(trim(geolocation_city)))          as city,
    mode(upper(trim(geolocation_state)))         as state,
    count(*)                                     as nb_points
from {{ source('olist', 'geolocation') }}
group by 1
