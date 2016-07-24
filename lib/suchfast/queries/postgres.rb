module Suchfast
  module Queries
    class Postgres
      QUERIES = [
        {
          code: 'BatchResults-Indexes',
          sql: "SELECT tablename as \"tableName\", indexname as \"indexName\", indexdef as \"indexDef\" FROM pg_indexes where schemaname='public'"
        },
        {
          code: 'BatchResults-QueryStats',
          sql: "SELECT query, calls, total_time as time, rows FROM pg_stat_statements WHERE (query not like '%pg_%') and (query not like '%_id_seq%') and (query like 'SELECT%') and (query like '%WHERE%');"
        },
        {
          code: 'BatchResults-TableStats',
          sql: "select relname as \"tableName\", reltuples as \"rowCount\", relpages as \"pageCount\", pg_size_pretty(relpages::bigint*8192) as \"prettyPageCount\" from pg_class join pg_tables on relname = tablename where schemaname = 'public';"
        },
        {
          code: 'BatchResults-ColumnStats',
          sql: "select tablename as \"tableName\", attname as \"columnName\", n_distinct as cardinality, null_frac as \"nullFrac\", correlation, most_common_freqs as \"mostCommonFreqs\" from pg_stats where schemaname = 'public';"
        }
      ]
    end
  end
end
