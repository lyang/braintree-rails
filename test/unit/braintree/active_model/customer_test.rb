require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::Customer do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    end

    it 'should find customer from braintree when given a customer id' do
      customer = Braintree::ActiveModel::Customer.new('customer_id')
      customer.id.must_equal 'customer_id'
      customer.persisted?.must_equal true
    end

    it 'should wrap a Braintree::Customer' do
      customer = Braintree::ActiveModel::Customer.new(Braintree::Customer.find('customer_id'))
      customer.id.must_equal 'customer_id'
      customer.persisted?.must_equal true
    end

    it 'should extract values from hash' do
      customer = Braintree::ActiveModel::Customer.new(:id => 'new_id')
      customer.id.must_equal 'new_id'
      customer.persisted?.must_equal false
    end
  end
end