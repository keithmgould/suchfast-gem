require 'rest-client'

module Suchfast
  class DataExporter
    class << self
      def export
        url = "https://79tolio5a2.execute-api.us-east-1.amazonaws.com/dev/harvester"

        batch = compile_batch

        RestClient.post url,
          batch.to_json,
          :content_type => :json,
          :accept => :json
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

      end
    end
  end
end
