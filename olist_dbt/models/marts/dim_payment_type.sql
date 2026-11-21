select
    payment_type,
    case payment_type
        when 'credit_card' then 'Carte de crédit'
        when 'debit_card'  then 'Carte de débit'
        when 'boleto'      then 'Boleto (virement bancaire)'
        when 'voucher'     then 'Bon / voucher'
        else 'Non défini'
    end as payment_type_label
from (select distinct payment_type from {{ ref('stg_order_payments') }})
