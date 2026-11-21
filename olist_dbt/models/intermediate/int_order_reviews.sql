-- Grain : une ligne = une commande.
-- Règle métier : une commande peut avoir plusieurs avis -> on garde le plus récent
-- (review_created_at, puis review_answered_at, puis review_id pour départager).
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by review_created_at desc, review_answered_at desc, review_id desc
        ) as rn,
        count(*) over (partition by order_id) as nb_reviews
    from {{ ref('stg_order_reviews') }}
)

select
    order_id,
    review_id,
    review_score,
    review_created_at,
    nb_reviews,
    review_comment_message is not null and trim(review_comment_message) <> '' as has_comment
from ranked
where rn = 1
