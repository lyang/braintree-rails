require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::Address do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    end

    it 'should wrap a Braintree::Address' do
      braintree_address = Braintree::Customer.find('customer_id').addresses.first
      address = Braintree::ActiveModel::Address.new(braintree_address)

      address.persisted?.must_equal true
      Braintree::ActiveModel::Address::Attributes.each do |attribute|
        address.send(attribute).must_equal braintree_address.send(attribute)
      end
    end

    it 'should extract values from hash' do
      address = Braintree::ActiveModel::Address.new(:id => 'new_id')

      address.persisted?.must_equal false
      address.id.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      address = Braintree::ActiveModel::Address.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      address.persisted?.must_equal true
      address.id.must_equal 'foobar'
      address.first_name.must_equal 'Foo'
      address.last_name.must_equal 'Bar'

      address = Braintree::ActiveModel::Address.new(Object.new)
      address.persisted?.must_equal false
    end
  end
end