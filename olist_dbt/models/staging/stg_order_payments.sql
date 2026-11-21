-- Grain : une ligne = un paiement d'une commande (order_id + payment_sequential)
-- Une commande peut avoir plusieurs paiements (ex. carte + voucher) : consolidation dans int_order_payments
select
    order_id,
    payment_sequential,
    lower(trim(payment_type))                 as payment_type,
    payment_installments,
    cast(payment_value as decimal(12, 2))     as payment_value
from {{ source('olist', 'order_payments') }}
