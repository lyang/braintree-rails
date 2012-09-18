Gem::Specification.new do |spec|
  spec.name        = 'braintree-rails'
  spec.version     = '0.2.0'
  spec.summary     = 'Provides ActiveModel compatible wrappers for Braintree models.'
  spec.description = 'Provides ActiveModel compatible wrappers for Braintree models and more.'
  spec.author      = 'Lin Yang'
  spec.email       = 'github@linyang.me'
  spec.license     = 'MIT'
  spec.files       = Dir['**/*']
  spec.test_files  = Dir['test/**']
  spec.homepage    = 'https://github.com/lyang/braintree-rails'
  spec.add_runtime_dependency 'braintree', '>= 2.16.0'
  spec.add_runtime_dependency 'activemodel', '>= 3.0'
  spec.add_runtime_dependency 'activesupport', '>= 3.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'turn'
end
