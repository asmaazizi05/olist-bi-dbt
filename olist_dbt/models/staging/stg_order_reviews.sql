-- Nettoyage et typage uniquement. Attention : une commande peut avoir plusieurs avis,
-- et un review_id peut apparaître sur plusieurs commandes. La déduplication se fait dans int_order_reviews.
select
    review_id,
    order_id,
    cast(review_score as integer)               as review_score,
    review_comment_title,
    review_comment_message,
    cast(review_creation_date as timestamp)     as review_created_at,
    cast(review_answer_timestamp as timestamp)  as review_answered_at
from {{ source('olist', 'order_reviews') }}
