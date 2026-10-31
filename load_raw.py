import duckdb, glob, os

con = duckdb.connect("olist.duckdb")
con.execute("CREATE SCHEMA IF NOT EXISTS raw")

for f in sorted(glob.glob("data/*.csv")):
    name = (os.path.basename(f)
            .replace("olist_", "")
            .replace("_dataset.csv", "")
            .replace(".csv", ""))
    con.execute(f"CREATE OR REPLACE TABLE raw.{name} AS SELECT * FROM read_csv_auto('{f}')")
    n = con.execute(f"SELECT COUNT(*) FROM raw.{name}").fetchone()[0]
    print(f"raw.{name}: {n} lignes")

con.close()
