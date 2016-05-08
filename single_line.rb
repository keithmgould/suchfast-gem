require 'httparty'

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
          sql: "select relname as \"tableName\", relpages as \"pageCount\", pg_size_pretty(relpages::bigint*8192) as \"prettyPageCount\" from pg_class join pg_tables on relname = tablename where schemaname = 'public';"
        },
        {
          code: 'BatchResults-ColumnStats',
          sql: "select tablename as \"tableName\", attname as \"columnName\", n_distinct as cardinality from pg_stats where schemaname = 'public' and (n_distinct > 100 or (n_distinct > -1 and n_distinct < -0.5));"
        }
      ]
    end
  end
end

module Suchfast
  class DataExporter
    class << self
      def export
        url = "https://79tolio5a2.execute-api.us-east-1.amazonaws.com/dev/harvester"

        options = {
          body: compile_batch.to_json,
          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        }

        HTTParty.post url, options
      end

      private

      def compile_batch
        batch = {}

        queries = Suchfast::Queries::Postgres::QUERIES

        queries.each do |query|
          batch[query[:code]] = run_query(query[:sql])
        end

        batch[:batchId] = SecureRandom.uuid
        batch[:token] = "12345abcdef"
        batch[:gemVersion] = "0.4.1"

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

Suchfast::DataExporter.export
