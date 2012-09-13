require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Customer Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should fetch customer from Braintree for given id' do
    braintree_customer = Braintree::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer = BraintreeRails::Customer.new(braintree_customer.id)
    customer.id.must_equal braintree_customer.id
    customer.first_name.must_equal 'Brain'
    customer.last_name.must_equal 'Tree'
    customer.persisted?.must_equal true
  end

  it 'should be able to create new customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    braintree_customer = Braintree::Customer.find(customer.id)

    braintree_customer.first_name.must_equal 'Brain'
    braintree_customer.last_name.must_equal 'Tree'
  end

  it 'should be able to update existing customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.update_attributes!(:first_name => 'Foo', :last_name => 'Bar')

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_customer.first_name.must_equal 'Foo'
    braintree_customer.last_name.must_equal 'Bar'
  end
end