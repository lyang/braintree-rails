require 'simplecov'
SimpleCov.start

require File.join(File.dirname(__FILE__), 'env')
require 'minitest/autorun'
require 'braintree-rails'
require 'turn/autorun'
require 'active_support/core_ext/date/calculations'
