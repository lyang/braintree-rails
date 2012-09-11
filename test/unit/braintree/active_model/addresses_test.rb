require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::Addresses do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::Address' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = Braintree::ActiveModel::Addresses.new(braintree_customer, braintree_addresses)
      
      addresses.size.must_equal braintree_addresses.size

      addresses.each do |address|
        braintree_address = braintree_addresses.find { |a| a.id == address.id }
        Braintree::ActiveModel::Address::Attributes.each do |attribute|
          address.send(attribute).must_equal braintree_address.send(attribute)
        end
      end
    end
  end

  describe '#build' do
    it 'should build new Address object with customer_id and params' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = Braintree::ActiveModel::Addresses.new(braintree_customer, braintree_addresses)
      address = addresses.build({:first_name => 'foo', :last_name => 'bar'})

      address.persisted?.must_equal false
      address.customer_id.must_equal braintree_customer.id
      address.first_name.must_equal 'foo'
      address.last_name.must_equal 'bar'
    end
  end
end