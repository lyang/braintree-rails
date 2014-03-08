require 'simplecov'
SimpleCov.start {add_filter '/spec/'}
require File.join(File.dirname(__FILE__), 'env')
require 'braintree-rails'
