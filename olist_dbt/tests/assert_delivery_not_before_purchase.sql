-- Test métier : la date de livraison ne doit jamais précéder la date d'achat.
-- severity warn : signale les anomalies de la source sans bloquer le pipeline.
{{ config(severity='warn') }}

select order_id, purchased_at, delivered_at
from {{ ref('stg_orders') }}
where delivered_at is not null
  and delivered_at < purchased_at
