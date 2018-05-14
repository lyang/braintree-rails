require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'braintree_rails', 'version')

Gem::Specification.new do |spec|
  spec.name        = 'braintree-rails'
  spec.version     = BraintreeRails::Version
  spec.summary     = 'Provides ActiveModel compatible wrappers for Braintree models.'
  spec.description = 'Provides ActiveModel compatible wrappers for Braintree models and more.'
  spec.author      = 'Lin Yang'
  spec.email       = 'github@linyang.me'
  spec.license     = 'MIT'
  spec.files       = `git ls-files`.split($/)
  spec.test_files  = Dir['spec/**']
  spec.homepage    = 'https://github.com/lyang/braintree-rails'
  spec.required_ruby_version = '>= 1.9.2'
  spec.add_runtime_dependency 'braintree', '>= 2.28.0', '< 3'
  spec.add_runtime_dependency 'activemodel', '>= 3.0', '< 5.3'
  spec.add_runtime_dependency 'activesupport', '>= 3.0', '< 5.3'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'webmock', '~> 1'
  spec.add_development_dependency 'coveralls', '~> 0'
end
