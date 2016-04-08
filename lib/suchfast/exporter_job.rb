module Suchfast
  class ExporterJob < ActiveJob::Base
    def perform
      Suchfast::DataExporter.export
    end
  end
end
