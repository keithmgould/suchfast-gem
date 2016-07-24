# Pasted together from a few files from the gem. Please ignore silly syntax.
#
# Instructions:
# 0. make sure you have httparty available
# 1. copy this entire file
# 2. paste into rails console

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
          sql: "SELECT query, calls, total_time as time, rows FROM pg_stat_statements WHERE calls > 100 and (query not like '%pg_%') and (query not like '%_id_seq%') and (query like 'SELECT%') and (query like '%WHERE%');"
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

module Suchfast
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

        queries = Suchfast::Queries::Postgres::QUERIES

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

Suchfast::DataExporter.export
