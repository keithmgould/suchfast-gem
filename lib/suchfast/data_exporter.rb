module Suchfast
  class DataExporter
    class << self
      def export
        fetch
        # RestClient.post "https://www.suchfast.com/mill",
        #   fetch.to_json,
        #   :content_type => :json,
        #   :accept => :json
      end

      private

      def fetch
        queries = Suchfast::Queries::Postgres::QUERIES

        queries.inject([]) do |sum, details|
          details[:data] = run_query(details[:query])
          sum << details

          sum
        end
      end

      def run_query(query)
        ActiveRecord::Base.connection.execute(query).to_a
      rescue
        
      end
    end 
  end
end
