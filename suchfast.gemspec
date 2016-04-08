# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'suchfast/version'

Gem::Specification.new do |spec|
  spec.name         = 'suchfast'
  spec.version      = Suchfast::VERSION
  spec.authors      = ['Suchfast Engineering']
  spec.email        = ['engineering@suchfast.com']
  spec.summary      = 'Suchfast Client'
  spec.description  = 'Client to asynchronously collect db data and send to Suchfast for analysis.'
  spec.homepage     = 'http://suchfast.com'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'clockwork'
  spec.add_dependency 'rest-client'
end
