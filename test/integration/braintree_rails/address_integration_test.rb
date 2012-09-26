require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Address Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to add address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    attributes = address_hash()
    customer.addresses.create!(attributes)
    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    
    attributes.each do |key, value|
      braintree_address.send(key).must_equal value
    end
  end

  it 'should be able to update existing address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    address = customer.addresses.create(address_hash)
    address.update_attributes(:first_name => 'Foo')

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    braintree_address.first_name.must_equal 'Foo'

    address.last_name = 'Bar'
    address.save!

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    braintree_address.last_name.must_equal 'Bar'
  end

  it 'should be able to destroy existing address' do
    customer = BraintreeRails::Customer.create!(customer_hash)
    address = customer.addresses.create!(address_hash)
    address.destroy!
    lambda{ Braintree::Address.find(customer.id, address.id) }.must_raise Braintree::NotFoundError
    address.persisted?.must_equal false
    address.frozen?.must_equal true
  end

end