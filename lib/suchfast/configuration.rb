module Suchfast
  class << self
    attr_accessor :configuration

    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration

  end
end
