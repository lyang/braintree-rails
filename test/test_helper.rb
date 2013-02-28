require File.expand_path(File.join(File.dirname(__FILE__), '../lib/test_env'))

TEST_PATH = File.expand_path(File.dirname(__FILE__))
FIXTURE_PATH = File.join(TEST_PATH, 'fixtures')

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = 'merchant_id'
Braintree::Configuration.public_key = 'public_key'
Braintree::Configuration.private_key = 'private_key'
Braintree::Configuration.logger = Logger.new(File.join(ROOT_PATH, 'log/braintree_test.log'))
BraintreeBaseUri = "https://#{Braintree::Configuration.public_key}:#{Braintree::Configuration.private_key}@#{Braintree::Configuration.environment}.braintreegateway.com/merchants/#{Braintree::Configuration.merchant_id}"

module TestHelper
  def fixture(name)
    File.read(File.join(FIXTURE_PATH, name)).gzip
  end

  def stub_braintree_request(method, path, response)
    response = response.reverse_merge(:headers => {'Content-Type' => ['application/xml', 'charset=utf-8'], 'Content-Encoding' => 'gzip'})
    stub_request(method, BraintreeBaseUri+path).to_return(response)
  end

  def address_hash
    {
      :first_name => 'Brain',
      :last_name => 'Tree',
      :company => 'Braintree',
      :street_address => "#{rand(1000..9999)} Crane Avenue",
      :extended_address => "Suite #{rand(100..999)}",
      :locality => 'Menlo Park',
      :region => 'California',
      :postal_code => ("00001".."99999").to_a.shuffle.first,
      :country_name => 'United States of America'
    }
  end

  def credit_card_hash
    {
      :token => 'credit_card_id',
      :number => (Braintree::Test::CreditCardNumbers::All - Braintree::Test::CreditCardNumbers::AmExes).shuffle.first,
      :cvv => ("100".."999").to_a.shuffle.first,
      :cardholder_name => 'Brain Tree',
      :expiration_month => ("01".."12").to_a.shuffle.first,
      :expiration_year => ("2012".."2035").to_a.shuffle.first,
      :billing_address => address_hash,
    }
  end

  def customer_hash
    {
      :first_name => "Brain#{rand(1..100)}",
      :last_name => "Tree#{rand(1..100)}"
    }
  end

  def subscription_hash
    {
      :id => 'subscription_id',
      :plan_id => 'plan_id',
      :payment_method_token => 'credit_card_id',
      :first_billing_date => Date.tomorrow
    }
  end
end


MiniTest::Unit::TestCase.class_eval do
  include TestHelper
end

String.class_eval do
  def gzip
    Zlib::GzipWriter.wrap(StringIO.new(gzipped = '')) { |gz| gz.write(self); gzipped }
  end
end
