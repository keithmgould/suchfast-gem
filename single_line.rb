module Deets
  module Queries
    class Postgres
      IndexQuery = <<-IndexQuery
        SELECT idx.indrelid::regclass as table_name,
               i.relname as index_name,
               ARRAY(
                  SELECT pg_get_indexdef(idx.indexrelid, k + 1, true)
                  FROM generate_subscripts(idx.indkey, 1) as k
                  ORDER BY k
               ) as column_names,
               pg_relation_size(idx.indexrelid) AS index_size,
               pg_size_pretty(pg_relation_size(idx.indexrelid)) AS pretty_index_size,
               sui.idx_scan AS index_scans,
               idx.indisunique AS index_unique,
               idx.indisprimary AS index_primary
        FROM   pg_index as idx
        JOIN   pg_class as i ON i.oid = idx.indexrelid
        JOIN   pg_am as am ON i.relam = am.oid
        JOIN   pg_stat_user_indexes sui on sui.indexrelid = idx.indexrelid
        JOIN   pg_namespace as ns ON ns.oid = i.relnamespace AND ns.nspname = ANY(current_schemas(false));
      IndexQuery

      ColumnQuery = <<-ColumnQuery
        select
            pgs.tablename as \"tableName\",
            pgs.attname as \"columnName\",
            n_distinct as cardinality,
            null_frac as \"nullFrac\",
            correlation,
            most_common_freqs as \"mostCommonFreqs\",
            attnotnull as \"attNotNull\",
            pgt.typname as \"typeName\"
        from
            pg_attribute pga
            join pg_class pgc on pga.attrelid = pgc.oid
            join pg_stats pgs on pgs.attname = pga.attname and pgs.tablename = pgc.relname
            join pg_type pgt on pga.atttypid = pgt.oid
        where
            schemaname = 'public';
      ColumnQuery

      ForeignKeyQuery = <<-ForeignKeyQuery
        SELECT
            tc.table_name as \"tableName\",
            kcu.column_name as \"columnName\"
        FROM
            information_schema.table_constraints AS tc
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
        WHERE constraint_type = 'FOREIGN KEY';
      ForeignKeyQuery

      QUERIES = [
        {
          code: 'BatchResults-Indexes',
          sql: IndexQuery
        },
        {
          code: 'BatchResults-QueryStats',
          sql: "SELECT query, calls, total_time as time, rows FROM pg_stat_statements WHERE calls > 100 and (query not like '%pg_%') and (query not like '%_id_seq%') and (query like 'SELECT%') and (query like '%WHERE%');"
        },
        {
          code: 'BatchResults-TableStats',
          sql: "select relname as \"tableName\", reltuples as \"rowCount\", relpages as \"pageCount\", pg_size_pretty(relpages::bigint*8192) as \"prettyPageCount\" from pg_class join pg_tables on relname = tablename where schemaname = 'public';"
        },
        {
          code: 'BatchResults-ColumnStats',
          sql: ColumnQuery
        },
        {
          code: 'BatchResults-ForeignKeys',
          sql: ForeignKeyQuery
        }
      ]
    end
  end
end

module Deets
  class DataExporter
    class << self
      def export
        url = "https://79tolio5a2.execute-api.us-east-1.amazonaws.com/dev/harvester"

        options = {
          body: compile_batch.to_json
        }

        uri = URI(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(uri.path)
        request.add_field('Content-Type', 'application/json')
        request.add_field('Accept', 'application/json')
        request.body = options[:body]

        response = https.request(request)
      rescue Exception => error
        puts error.inspect
      end

      private

      def compile_batch
        batch = {}

        queries = Deets::Queries::Postgres::QUERIES

        queries.each do |query|
          batch[query[:code]] = run_query(query[:sql])
        end

        created_at_ms = (Time.now.utc.to_f * 1000).to_i
        batch[:batchId] = "#{created_at_ms}:#{SecureRandom.uuid}"
        batch[:token] = "12345abcdef"

        puts "batchId: #{batch[:batchId]}"

        batch
      end

      def run_query(query)
        ActiveRecord::Base.connection.execute(query).to_a
      rescue
        puts "something didnt work :("
      end
    end
  end
end

Deets::DataExporter.export
