-- Grain : une ligne = une commande.
-- Règle métier : consolider les paiements multiples d'une commande.
-- main_payment_type = mode de paiement qui représente le plus grand montant (égalité : le premier paiement).
with payments as (
    select * from {{ ref('stg_order_payments') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by payment_value desc, payment_sequential asc
        ) as rn
    from payments
),

main_type as (
    select order_id, payment_type as main_payment_type
    from ranked
    where rn = 1
),

agg as (
    select
        order_id,
        count(*)                              as nb_payments,
        sum(payment_value)                    as total_payment_value,
        -- 0 échéance dans les données brutes = valeur invalide, ramenée à 1
        greatest(max(payment_installments), 1) as payment_installments
    from payments
    group by order_id
)

select
    a.order_id,
    a.nb_payments,
    a.total_payment_value,
    a.payment_installments,
    m.main_payment_type
from agg a
join main_type m using (order_id)
