-- Test métier : aucun prix, frais de port ou paiement négatif
select 'order_items' as source, order_id from {{ ref('stg_order_items') }} where price < 0 or freight_value < 0
union all
select 'order_payments', order_id from {{ ref('stg_order_payments') }} where payment_value < 0
