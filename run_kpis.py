"""Exécute les 10 KPI de olist_dbt/analyses/kpi_queries.sql sur olist.duckdb.
Usage (depuis la racine du dépôt, après `dbt build`) : python run_kpis.py
"""
import re
import duckdb

SQL_FILE = "olist_dbt/analyses/kpi_queries.sql"

sql = open(SQL_FILE, encoding="utf-8").read()
sql = re.sub(r"\{\{\s*ref\('(\w+)'\)\s*\}\}", r"main.\1", sql)  # ref() -> main.<table>

con = duckdb.connect("olist.duckdb", read_only=True)
titles = re.findall(r"^-- (\d+\. .*)$", sql, flags=re.M)
queries = [q.strip() for q in sql.split(";") if "select" in q.lower()]

for title, q in zip(titles, queries):
    print(f"\n=== KPI {title}")
    print(con.sql(q))
con.close()
