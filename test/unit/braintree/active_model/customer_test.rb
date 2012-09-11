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

  describe '#credit_cards' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = Braintree::ActiveModel::Customer.new(braintree_customer)

      customer.credit_cards.must_be_kind_of(Enumerable)
      customer.credit_cards.size.must_equal braintree_customer.credit_cards.size
    end
  end

  describe 'validations' do
    it 'should validate id' do
      customer = Braintree::ActiveModel::Customer.new({})
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => '%'})
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => 'all'})
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => 'new'})
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => 'f' * 37})
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => 'f'})
      customer.valid?
      customer.errors[:id].must_be :blank?

      customer = Braintree::ActiveModel::Customer.new({:id => 'f' * 36})
      customer.valid?
      customer.errors[:id].must_be :blank?
    end

    [:first_name, :last_name, :company, :website, :phone, :fax].each do |attribute|
      it "should validate length of #{attribute}" do
        address = Braintree::ActiveModel::Customer.new(attribute => 'f')
        address.valid?
        address.errors[attribute].must_be :blank?

        address = Braintree::ActiveModel::Customer.new(attribute => 'f' * 255)
        address.valid?
        address.errors[attribute].must_be :blank?

        address = Braintree::ActiveModel::Customer.new(attribute => 'foo' * 256)
        address.valid?
        address.errors[attribute].wont_be :blank?
      end
    end
  end
end