require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::Customer do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should find customer from braintree when given a customer id' do
      customer = Braintree::ActiveModel::Customer.new('customer_id')
      braintree_customer = Braintree::Customer.find('customer_id')

      customer.persisted?.must_equal true
      Braintree::ActiveModel::Customer::Attributes.each do |attribute|
        customer.send(attribute).must_equal braintree_customer.send(attribute)
      end
    end

    it 'should wrap a Braintree::Customer' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = Braintree::ActiveModel::Customer.new(braintree_customer)

      customer.persisted?.must_equal true
      Braintree::ActiveModel::Customer::Attributes.each do |attribute|
        customer.send(attribute).must_equal braintree_customer.send(attribute)
      end
    end

    it 'should extract values from hash' do
      customer = Braintree::ActiveModel::Customer.new(:id => 'new_id')

      customer.persisted?.must_equal false
      customer.id.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      customer = Braintree::ActiveModel::Customer.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      customer.persisted?.must_equal true
      customer.id.must_equal 'foobar'
      customer.first_name.must_equal 'Foo'
      customer.last_name.must_equal 'Bar'

      customer = Braintree::ActiveModel::Customer.new(OpenStruct.new({}))
      customer.persisted?.must_equal false
    end
  end

  describe '#addresses' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = Braintree::ActiveModel::Customer.new(braintree_customer)

      customer.addresses.must_be_kind_of(Enumerable)
      customer.addresses.size.must_equal braintree_customer.addresses.size
    end
  end
end