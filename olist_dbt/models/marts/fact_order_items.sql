-- Table de faits. Grain : une ligne = un article d'une commande (order_id + order_item_id).
-- Choix de nettoyage : on exclut les commandes 'canceled' et 'unavailable' (pas de vente réelle).
-- Les mesures de livraison sont NULL tant que la commande n'est pas livrée.
-- Les mesures de niveau commande (review_score, payment_installments) sont répétées sur chaque article :
-- ne jamais les additionner, les agréger par commande distincte.
with items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

reviews  as (select * from {{ ref('int_order_reviews') }}),
payments as (select * from {{ ref('int_order_payments') }})

select
    i.order_id,
    i.order_item_id,
    -- clés vers les dimensions
    o.customer_id,
    i.seller_id,
    i.product_id,
    cast(o.purchased_at as date)  as purchase_date_key,
    cast(o.delivered_at as date)  as delivered_date_key,
    p.main_payment_type           as payment_type,
    o.order_status,
    -- mesures
    i.price,
    i.freight_value,
    i.price + i.freight_value     as item_total,
    date_diff('day', cast(o.purchased_at as date), cast(o.delivered_at as date))          as delivery_days,
    date_diff('day', cast(o.estimated_delivery_at as date), cast(o.delivered_at as date)) as delay_days,
    case
        when o.delivered_at is null then null
        else cast(o.delivered_at as date) > cast(o.estimated_delivery_at as date)
    end                           as is_late,
    r.review_score,
    p.payment_installments
from items i
join orders o on i.order_id = o.order_id
left join reviews  r on i.order_id = r.order_id
left join payments p on i.order_id = p.order_id
