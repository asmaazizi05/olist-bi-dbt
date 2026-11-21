-- Le grain de la table de faits (order_id, order_item_id) doit être unique
select order_id, order_item_id, count(*) as n
from {{ ref('fact_order_items') }}
group by 1, 2
having count(*) > 1
