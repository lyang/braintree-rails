require File.expand_path(File.join(File.dirname(__FILE__), '../lib/test_env'))

TEST_PATH = File.expand_path(File.dirname(__FILE__))
FIXTURE_PATH = File.join(TEST_PATH, 'fixtures')

BraintreeRails::Configuration.environment = :sandbox
BraintreeRails::Configuration.merchant_id = 'merchant_id'
BraintreeRails::Configuration.public_key = 'public_key'
BraintreeRails::Configuration.private_key = 'private_key'
BraintreeRails::Configuration.default_merchant_account_id = 'default_merchant_account_id'
BraintreeRails::Configuration.logger = Logger.new('/dev/null').tap { |logger| logger.level = Logger::INFO }
BraintreeBaseUri = "https://#{Braintree::Configuration.public_key}:#{Braintree::Configuration.private_key}@api.#{Braintree::Configuration.environment}.braintreegateway.com/merchants/#{Braintree::Configuration.merchant_id}"

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
      :street_address => "#{(1000..9999).to_a.sample} Crane Avenue",
      :extended_address => "Suite #{(100..999).to_a.sample}",
      :locality => 'Menlo Park',
      :region => 'CA',
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
      :first_name => "Brain#{(1..100).to_a.sample}",
      :last_name => "Tree#{(1..100).to_a.sample}"
    }
  end

  def subscription_hash
    {
      :id => 'subscription_id',
      :plan_id => 'plan_id',
      :payment_method_token => 'credit_card_id',
      :first_billing_date => Date.tomorrow,
      :price => ''
    }
  end

  def merchant_account_hash
    {
      :master_merchant_account_id => BraintreeRails::Configuration.default_merchant_account_id,
      :tos_accepted => true,
      :individual => {:first_name => "Brain", :last_name => "Tree", :email => "braintree-rails@exameple.com", :date_of_birth => "2014-01-01", :address => address_hash},
      :funding => {:destination => Braintree::MerchantAccount::FundingDestination::Email, :email => "braintree-rails@exameple.com"},
      :business => {:legal_name => "braintree-rails", :dba_name => "braintree-rails", :tax_id => "98-7654321"},
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
