require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Addresses do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::Address' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = BraintreeRails::Addresses.new(BraintreeRails::Customer.find('customer_id'))

      expect(addresses.size).to eq(braintree_addresses.size)

      braintree_addresses.each do |braintree_address|
        address = addresses.find(braintree_address.id)
        BraintreeRails::Address.attributes.each do |attribute|
          expect(address.send(attribute)).to eq(braintree_address.send(attribute))
        end
      end
    end
  end

  describe '#build' do
    it 'should build new Address object with customer_id and params' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_addresses = braintree_customer.addresses
      addresses = BraintreeRails::Addresses.new(BraintreeRails::Customer.find('customer_id'))
      address = addresses.build({:first_name => 'foo', :last_name => 'bar'})

      expect(address).to_not be_persisted
      expect(address.customer_id).to eq(braintree_customer.id)
      expect(address.first_name).to eq('foo')
      expect(address.last_name).to eq('bar')
    end
  end
end
