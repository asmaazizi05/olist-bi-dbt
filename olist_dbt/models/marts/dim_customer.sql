select
    c.customer_id,
    c.customer_unique_id,
    c.city,
    c.state,
    coalesce(r.region, 'Inconnue') as region,
    g.latitude,
    g.longitude
from {{ ref('stg_customers') }} c
left join {{ ref('ref_state_region') }} r on c.state = r.state
left join {{ ref('stg_geolocation') }} g on c.zip_code_prefix = g.zip_code_prefix