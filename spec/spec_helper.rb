require File.expand_path(File.join(File.dirname(__FILE__), '../lib/test_env'))
I18n.enforce_available_locales = false

SPEC_PATH = File.expand_path(File.dirname(__FILE__))
FIXTURE_PATH = File.join(SPEC_PATH, 'fixtures')

BraintreeRails::Configuration.environment = :sandbox
BraintreeRails::Configuration.merchant_id = 'merchant_id'
BraintreeRails::Configuration.public_key = 'public_key'
BraintreeRails::Configuration.private_key = 'private_key'
BraintreeRails::Configuration.default_merchant_account_id = 'default_merchant_account_id'
BraintreeRails::Configuration.logger = Logger.new('/dev/null').tap { |logger| logger.level = Logger::INFO }
BraintreeBaseUri = "https://#{Braintree::Configuration.public_key}:#{Braintree::Configuration.private_key}@api.#{Braintree::Configuration.environment}.braintreegateway.com/merchants/#{Braintree::Configuration.merchant_id}"

Dir[File.join(SPEC_PATH, "support/**/*.rb")].each { |f| require f }
RSpec.configure do |config|
  config.include Helper
end
