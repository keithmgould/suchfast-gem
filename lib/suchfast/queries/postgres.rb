module Suchfast
  module Queries
    class Postgres
      QUERIES = [
        {
          query_code: :pg_indexes,
          query: "SELECT tablename, indexname, indexdef FROM pg_indexes where schemaname='public'"
        },
        {
          query_code: :pg_stat_statements,
          query: "SELECT query, calls, total_time, rows FROM pg_stat_statements"
        },
        {
          query_code: :tables,
          query: "select relname, relpages, pg_size_pretty(relpages::bigint*8192) from pg_class join pg_tables on relname = tablename where schemaname = 'public';"
        }
      ]
    end
  end
end
