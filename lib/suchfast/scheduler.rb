require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork
  every(3.hours, 'Send data to Suchfast.com') do
    Suchfast::ExporterJob.perform_async
  end

  error_handler do |error|
    # Do it
  end
end

