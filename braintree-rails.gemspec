require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'braintree_rails', 'version')

Gem::Specification.new do |spec|
  spec.name        = 'braintree-rails'
  spec.version     = BraintreeRails::Version
  spec.summary     = 'Provides ActiveModel compatible wrappers for Braintree models.'
  spec.description = 'Provides ActiveModel compatible wrappers for Braintree models and more.'
  spec.author      = 'Lin Yang'
  spec.email       = 'github@linyang.me'
  spec.license     = 'MIT'
  spec.files       = Dir['**/*']
  spec.test_files  = Dir['test/**']
  spec.homepage    = 'https://github.com/lyang/braintree-rails'
  spec.required_ruby_version = '>= 1.9.2'
  spec.add_runtime_dependency 'braintree', '>= 2.16.0'
  spec.add_runtime_dependency 'activemodel', '>= 3.0'
  spec.add_runtime_dependency 'activesupport', '>= 3.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'turn'
  spec.add_development_dependency 'simplecov'
end
