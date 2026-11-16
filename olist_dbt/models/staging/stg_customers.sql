select
    customer_id,
    customer_unique_id,
    cast(customer_zip_code_prefix as varchar) as zip_code_prefix,
    lower(trim(customer_city))                as city,
    upper(trim(customer_state))               as state
from {{ source('olist', 'customers') }}
