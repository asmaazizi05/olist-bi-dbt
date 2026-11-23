# Power BI : modèle et mesures DAX

## 1. Exporter les données
```powershell
python export_powerbi.py
```
Crée `powerbi/data/*.parquet` (6 tables). Relancer après chaque `dbt build`.

## 2. Importer dans Power BI Desktop
Accueil > Obtenir les données > **Parquet** > importer les 6 fichiers (un par un, ou via Dossier).
Ne pas faire « Transformer » : les types sont déjà bons.

## 3. Relations (onglet Modèle)
| De (fact_order_items) | Vers | Cardinalité | Active |
|---|---|---|---|
| customer_id | dim_customer[customer_id] | plusieurs à un | oui |
| seller_id | dim_seller[seller_id] | plusieurs à un | oui |
| product_id | dim_product[product_id] | plusieurs à un | oui |
| payment_type | dim_payment_type[payment_type] | plusieurs à un | oui |
| purchase_date_key | dim_date[date_key] | plusieurs à un | oui |
| delivered_date_key | dim_date[date_key] | plusieurs à un | **non** (inactive) |

Sens du filtre : unique (dimension vers fait). Marquer `dim_date` comme table de dates (clic droit > Marquer comme table de dates > `date_key`).

## 4. Mesures DAX (créer dans une table « _Mesures » ou dans fact_order_items)
Les noms de tables/colonnes sont ceux des marts. Les mesures de niveau commande
(note, retard) sont calculées par commande distincte, comme dans `kpi_queries.sql`.

```DAX
-- 1. Chiffre d'affaires (hors frais de port)
Revenue = SUM ( fact_order_items[price] )

-- 2. Nombre de commandes
Nb Orders = DISTINCTCOUNT ( fact_order_items[order_id] )

-- 3. Panier moyen
Avg Basket = DIVIDE ( [Revenue], [Nb Orders] )

-- 4. Panier moyen par nombre d'échéances : utiliser [Avg Basket]
--    avec fact_order_items[payment_installments] en axe (ou une tranche, voir plus bas)

-- 5. Délai moyen de livraison (jours)
Avg Delivery Days =
CALCULATE (
    AVERAGE ( fact_order_items[delivery_days] ),
    NOT ISBLANK ( fact_order_items[delivered_date_key] )
)

-- 6. Taux de retard (par commande)
Delivered Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_order_items[order_id] ),
    NOT ISBLANK ( fact_order_items[delivered_date_key] )
)
Late Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_order_items[order_id] ),
    fact_order_items[is_late] = TRUE ()
)
Late Rate = DIVIDE ( [Late Orders], [Delivered Orders] )

-- 7. Note moyenne (par commande)
Avg Review Score =
AVERAGEX (
    VALUES ( fact_order_items[order_id] ),
    CALCULATE ( MAX ( fact_order_items[review_score] ) )
)

-- 8. Part d'avis négatifs (note <= 2, par commande)
Negative Reviews =
CALCULATE (
    DISTINCTCOUNT ( fact_order_items[order_id] ),
    fact_order_items[review_score] <= 2
)
Reviewed Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_order_items[order_id] ),
    NOT ISBLANK ( fact_order_items[review_score] )
)
Negative Share = DIVIDE ( [Negative Reviews], [Reviewed Orders] )

-- 9. Taux de clients récurrents (par customer_unique_id)
Customers =
DISTINCTCOUNT ( dim_customer[customer_unique_id] )
Repeat Customers =
COUNTROWS (
    FILTER (
        VALUES ( dim_customer[customer_unique_id] ),
        CALCULATE ( DISTINCTCOUNT ( fact_order_items[order_id] ) ) > 1
    )
)
Repeat Rate = DIVIDE ( [Repeat Customers], [Customers] )

-- 10. Concentration : part du CA des 10 premiers vendeurs
Top10 Seller Share =
DIVIDE (
    SUMX ( TOPN ( 10, ALL ( dim_seller[seller_id] ), [Revenue] ), [Revenue] ),
    CALCULATE ( [Revenue], ALL ( dim_seller ) )
)
```

Colonne calculée utile (table fact_order_items) pour regrouper les échéances :
```DAX
Installments Band =
SWITCH (
    TRUE (),
    fact_order_items[payment_installments] = 1, "1x",
    fact_order_items[payment_installments] <= 3, "2-3x",
    fact_order_items[payment_installments] <= 6, "4-6x",
    fact_order_items[payment_installments] <= 10, "7-10x",
    "Plus de 10x"
)
```

## 5. Valeurs de contrôle (doivent correspondre à `python run_kpis.py`)
Revenue 13 494 400,74 | Nb Orders 98 199 | Avg Basket 137,42 | Avg Delivery Days 12,41 |
Late Rate 6,77 % | Avg Review Score 4,12 | Negative Share 13,87 % |
Repeat Rate 3,04 % | Top10 Seller Share 13,20 %.
Si Power BI affiche d'autres valeurs, vérifier les relations et les mesures.

## 6. Pages du tableau de bord
1. **Ventes** : cartes (Revenue, Nb Orders, Avg Basket), CA par mois (dim_date[year_month]), top 10 catégories (dim_product[category]), CA par région (dim_customer[region]).
2. **Logistique** : Avg Delivery Days, Late Rate, retard par état/région du vendeur, évolution mensuelle du taux de retard, impact des jours fériés (dim_date[is_holiday_or_event]).
3. **Satisfaction** : Avg Review Score, Negative Share, note par catégorie, lien retard / note (Late Rate vs Avg Review Score).
4. **Vendeurs** : Top10 Seller Share, classement des vendeurs par CA, note et retard par vendeur, carte (dim_seller latitude/longitude).
Segments communs sur toutes les pages : année, région, catégorie.
