require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require 'yaml'
SimpleCov.command_name "spec:integration"

config = File.join(SPEC_PATH, 'config/braintree_auth.yml')
if File.exist?(config) && auth = YAML.load_file(config)
  BraintreeRails::Configuration.environment = :sandbox
  BraintreeRails::Configuration.merchant_id = auth['merchant_id']
  BraintreeRails::Configuration.public_key = auth['public_key']
  BraintreeRails::Configuration.private_key = auth['private_key']
  BraintreeRails::Configuration.default_merchant_account_id = auth['default_merchant_account_id']
  # BraintreeRails::Configuration.logger = Logger.new('log/braintree.log')
elsif ENV["TRAVIS_SECURE_ENV_VARS"] == "true" && ENV["TRAVIS_RUBY_VERSION"] == "2.0.0"
  BraintreeRails::Configuration.environment = :sandbox
  BraintreeRails::Configuration.merchant_id = ENV['merchant_id']
  BraintreeRails::Configuration.public_key = ENV['public_key']
  BraintreeRails::Configuration.private_key = ENV['private_key']
  BraintreeRails::Configuration.default_merchant_account_id = ENV['default_merchant_account_id']
else
  puts '*' * 80
  puts "You need to provide real credentials in #{config} to run integration tests"
  puts '*' * 80
  exit(0)
end
