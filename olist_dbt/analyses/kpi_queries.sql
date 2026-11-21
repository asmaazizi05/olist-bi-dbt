-- Requêtes des 10 KPI. Compiler avec `dbt compile`, ou copier le SQL dans DuckDB
-- (remplacer {{ ref('fact_order_items') }} par main.fact_order_items).

-- 1. Chiffre d'affaires (hors frais de port)
select sum(price) as revenue from {{ ref('fact_order_items') }};

-- 2. Nombre de commandes
select count(distinct order_id) as nb_orders from {{ ref('fact_order_items') }};

-- 3. Panier moyen = CA / commandes
select sum(price) / count(distinct order_id) as avg_basket from {{ ref('fact_order_items') }};

-- 4. Panier moyen par nombre d'échéances
select payment_installments,
       sum(price) / count(distinct order_id) as avg_basket,
       count(distinct order_id)              as nb_orders
from {{ ref('fact_order_items') }}
group by 1 order by 1;

-- 5. Délai moyen de livraison (jours, commandes livrées)
select avg(delivery_days) as avg_delivery_days
from {{ ref('fact_order_items') }} where delivered_date_key is not null;

-- 6. Taux de retard (par commande)
select avg(case when is_late then 1.0 else 0.0 end) as late_rate
from (select order_id, bool_or(is_late) as is_late
      from {{ ref('fact_order_items') }} where is_late is not null group by 1);

-- 7. Note moyenne (par commande)
select avg(review_score) as avg_score
from (select order_id, any_value(review_score) as review_score
      from {{ ref('fact_order_items') }} where review_score is not null group by 1);

-- 8. Part d'avis négatifs (note <= 2)
select avg(case when review_score <= 2 then 1.0 else 0.0 end) as negative_share
from (select order_id, any_value(review_score) as review_score
      from {{ ref('fact_order_items') }} where review_score is not null group by 1);

-- 9. Taux de clients récurrents (plus d'une commande, par customer_unique_id)
select avg(case when nb_orders > 1 then 1.0 else 0.0 end) as repeat_rate
from (select c.customer_unique_id, count(distinct f.order_id) as nb_orders
      from {{ ref('fact_order_items') }} f
      join {{ ref('dim_customer') }} c using (customer_id)
      group by 1);

-- 10. Concentration des ventes : part du CA des 10 premiers vendeurs
select sum(rev) / (select sum(price) from {{ ref('fact_order_items') }}) as top10_share
from (select seller_id, sum(price) as rev
      from {{ ref('fact_order_items') }}
      group by 1 order by rev desc limit 10);
