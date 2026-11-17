select
    s.seller_id,
    s.city,
    s.state,
    coalesce(r.region, 'Inconnue') as region,
    g.latitude,
    g.longitude
from {{ ref('stg_sellers') }} s
left join {{ ref('ref_state_region') }} r on s.state = r.state
left join {{ ref('stg_geolocation') }} g on s.zip_code_prefix = g.zip_code_prefix