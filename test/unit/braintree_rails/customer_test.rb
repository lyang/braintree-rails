require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Customer do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should find customer from braintree when given a customer id' do
      customer = BraintreeRails::Customer.new('customer_id')
      braintree_customer = Braintree::Customer.find('customer_id')

      customer.persisted?.must_equal true
      BraintreeRails::Customer::Attributes.each do |attribute|
        customer.send(attribute).must_equal braintree_customer.send(attribute)
      end
    end

    it 'should wrap a Braintree::Customer' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      customer.persisted?.must_equal true
      BraintreeRails::Customer::Attributes.each do |attribute|
        customer.send(attribute).must_equal braintree_customer.send(attribute)
      end
    end

    it 'should extract values from hash' do
      customer = BraintreeRails::Customer.new(:id => 'new_id')

      customer.persisted?.must_equal false
      customer.id.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      customer = BraintreeRails::Customer.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      customer.persisted?.must_equal true
      customer.id.must_equal 'foobar'
      customer.first_name.must_equal 'Foo'
      customer.last_name.must_equal 'Bar'

      customer = BraintreeRails::Customer.new(OpenStruct.new())
      customer.persisted?.must_equal false
    end
  end

  describe '#addresses' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      customer.addresses.must_be_kind_of(Enumerable)
      customer.addresses.size.must_equal braintree_customer.addresses.size
    end
  end

  describe '#credit_cards' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      customer.credit_cards.must_be_kind_of(Enumerable)
      customer.credit_cards.size.must_equal braintree_customer.credit_cards.size
    end
  end

  describe 'validations' do
    it 'should validate id' do
      customer = BraintreeRails::Customer.new(:id => '%')
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = BraintreeRails::Customer.new(:id => 'all')
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = BraintreeRails::Customer.new(:id => 'new')
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = BraintreeRails::Customer.new(:id => 'f' * 37)
      customer.valid?
      customer.errors[:id].wont_be :blank?

      customer = BraintreeRails::Customer.new({})
      customer.valid?
      customer.errors[:id].must_be :blank?

      customer = BraintreeRails::Customer.new(:id => 'f')
      customer.valid?
      customer.errors[:id].must_be :blank?

      customer = BraintreeRails::Customer.new(:id => 'f' * 36)
      customer.valid?
      customer.errors[:id].must_be :blank?
    end

    [:first_name, :last_name, :company, :website, :phone, :fax].each do |attribute|
      it "should validate length of #{attribute}" do
        customer = BraintreeRails::Customer.new(attribute => 'f')
        customer.valid?
        customer.errors[attribute].must_be :blank?

        customer = BraintreeRails::Customer.new(attribute => 'f' * 255)
        customer.valid?
        customer.errors[attribute].must_be :blank?

        customer = BraintreeRails::Customer.new(attribute => 'foo' * 256)
        customer.valid?
        customer.errors[attribute].wont_be :blank?
      end
    end
  end

  describe 'persistence' do
    before do
      stub_braintree_request(:post, '/customers', :body => fixture('customer.xml'))
      stub_braintree_request(:put, '/customers/customer_id', :body => fixture('customer.xml'))
    end

    describe 'save, save!' do
      it 'should return true when saved' do
        customer = BraintreeRails::Customer.new()
        customer.save.must_equal true
        customer.persisted?.must_equal true
      end

      it 'should not throw error when not valid' do
        customer = BraintreeRails::Customer.new(:first_name => 'f' * 256)
        customer.save.must_equal false
        customer.persisted?.must_equal false
      end

      it 'should return true when saved with bang' do
        customer = BraintreeRails::Customer.new()
        customer.save!.must_equal true
        customer.persisted?.must_equal true
      end

      it 'should throw error when save invalid record with bang' do
        customer = BraintreeRails::Customer.new(:first_name => 'f' * 256)
        lambda{ customer.save! }.must_raise(RecordInvalid)
        customer.persisted?.must_equal false
      end
    end

    describe 'update_attributes, update_attributes!' do
      it 'should return true when update_attributes' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        customer.update_attributes(:first_name => 'f').must_equal true
      end

      it 'should not throw error when not valid' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        customer.update_attributes(:first_name => 'f' * 256).must_equal false
      end

      it 'should return true when update_attributesd with bang' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        customer.update_attributes!(:first_name => 'f').must_equal true
      end

      it 'should throw error when update_attributes invalid record with bang' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        lambda{ customer.update_attributes!(:first_name => 'f' * 256) }.must_raise(RecordInvalid)
      end
    end
  end
end