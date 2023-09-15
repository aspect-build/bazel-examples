"""Providers for the Prisma subsystem."""

PrismaSchemaInfo = provider(
    doc = """Provider for prisma schema info.""",
    fields = {
        "db_url_env": "Environment variable for db url.",
        "schema": "Prisma schema.",
    },
)

PrismaEnginesInfo = provider(
    doc = "Provider for a set of prisma engines",
    fields = {
        "libquery_engine": "Query engine (lib)",
        "query_engine": "Query engine (bin)",
        "schema_engine": "Schema engine (bin)",
    },
)
