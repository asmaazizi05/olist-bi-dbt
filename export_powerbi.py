"""Exporte les tables du schéma en étoile (marts dbt) en Parquet pour Power BI.
Usage (depuis la racine du dépôt, après `dbt build`) : python export_powerbi.py
Résultat : dossier powerbi/data/ (ignoré par Git, voir .gitignore).
"""
import os
import duckdb

TABLES = ["fact_order_items", "dim_date", "dim_customer",
          "dim_seller", "dim_product", "dim_payment_type"]

os.makedirs("powerbi/data", exist_ok=True)
con = duckdb.connect("olist.duckdb", read_only=True)

for t in TABLES:
    out = f"powerbi/data/{t}.parquet"
    con.execute(f"COPY (SELECT * FROM main.{t}) TO '{out}' (FORMAT PARQUET)")
    n = con.execute(f"SELECT COUNT(*) FROM main.{t}").fetchone()[0]
    print(f"{t}: {n} lignes -> {out}")

con.close()
