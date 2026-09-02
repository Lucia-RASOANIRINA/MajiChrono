import psycopg

DSN = (
    "postgresql://neondb_owner:npg_mIUElK9Fv7PA@"
    "ep-twilight-field-ax0q5omb-pooler.c-4.us-east-2.aws.neon.tech/neondb"
    "?sslmode=require"
)

conn = psycopg.connect(DSN)
cur = conn.cursor()
cur.execute(
    "select table_name from information_schema.tables "
    "where table_schema='public' order by 1"
)
tables = [row[0] for row in cur.fetchall()]
print("TABLES:", tables)

for t in tables:
    cur.execute(f'select count(*) from "{t}"')
    print(t, "->", cur.fetchone()[0])

conn.close()
