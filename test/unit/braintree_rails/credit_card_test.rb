require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::CreditCard do
  before do
    stub_braintree_request(:get, '/payment_methods/credit_card_id', :body => fixture('credit_card.xml'))
  end

  describe '#initialize' do
    it 'should find credit_card from braintree when given a credit_card id' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')

      credit_card.persisted?.must_equal true
      BraintreeRails::CreditCard.attributes.each do |attribute|
        credit_card.send(attribute).must_equal(braintree_credit_card.send(attribute)) if braintree_credit_card.respond_to?(attribute)
      end
    end

    it 'should wrap a Braintree::CreditCard' do
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')
      credit_card = BraintreeRails::CreditCard.new(braintree_credit_card)

      credit_card.persisted?.must_equal true
      BraintreeRails::CreditCard.attributes.each do |attribute|
        credit_card.send(attribute).must_equal(braintree_credit_card.send(attribute)) if braintree_credit_card.respond_to?(attribute)
      end
    end

    it 'should extract values from hash' do
      credit_card = BraintreeRails::CreditCard.new(:token => 'new_id')

      credit_card.persisted?.must_equal false
      credit_card.token.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:token => 'foobar', :cardholder_name => 'Foo Bar', :persisted? => true))

      credit_card.persisted?.must_equal true
      credit_card.token.must_equal 'foobar'
      credit_card.cardholder_name.must_equal 'Foo Bar'

      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new)
      credit_card.persisted?.must_equal false
    end
  end

  describe 'customer' do
    it 'should load customer for persisted credit_card' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
      credit_card.customer.persisted?.must_equal true
      credit_card.customer.id.must_equal 'customer_id'
    end
  end

  describe '#billing_address' do
    it 'should wrap billing_address with Address object' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:billing_address => {}))
      credit_card.billing_address.class.ancestors.must_include BraintreeRails::Address

      credit_card.billing_address = BraintreeRails::Address.new
      credit_card.billing_address.class.ancestors.must_include BraintreeRails::Address
    end

    it 'should keep billing_address nil if assigned nil value' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:billing_address => nil))
      credit_card.billing_address.class.must_equal NilClass
    end

  end

  describe 'validations' do
    it 'should validate precence of customer_id if new_record?' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      credit_card.errors[:customer_id].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo')
      credit_card.valid?
      credit_card.errors[:customer_id].must_be :blank?
    end

    it 'should validate length of customer_id' do
      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo' * 13)
      credit_card.valid?
      credit_card.errors[:customer_id].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo')
      credit_card.valid?
      credit_card.errors[:customer_id].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo' * 12)
      credit_card.valid?
      credit_card.errors[:customer_id].must_be :blank?
    end

    it 'should validate precence of number if new_record?' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      credit_card.errors[:number].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
      credit_card.valid?
      credit_card.errors[:number].must_be :blank?
    end

    it 'should validate numericality of number' do
      credit_card = BraintreeRails::CreditCard.new(:number => 'foobar')
      credit_card.valid?
      credit_card.errors[:number].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
      credit_card.valid?
      credit_card.errors[:number].must_be :blank?
    end

    it 'should validate length of number' do
      credit_card = BraintreeRails::CreditCard.new(:number => '1')
      credit_card.valid?
      credit_card.errors[:number].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:number => '1' * 20)
      credit_card.valid?
      credit_card.errors[:number].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
      credit_card.valid?
      credit_card.errors[:number].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:number => '6208645006512478950')
      credit_card.valid?
      credit_card.errors[:number].must_be :blank?
    end

    it 'should validate precence of cvv' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      credit_card.errors[:cvv].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
      credit_card.valid?
      credit_card.errors[:cvv].must_be :blank?
    end

    it 'should validate numericality of cvv' do
      credit_card = BraintreeRails::CreditCard.new(:cvv => 'foo')
      credit_card.valid?
      credit_card.errors[:cvv].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
      credit_card.valid?
      credit_card.errors[:cvv].must_be :blank?
    end

    it 'should validate length of cvv' do
      credit_card = BraintreeRails::CreditCard.new(:cvv => '1')
      credit_card.valid?
      credit_card.errors[:cvv].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cvv => '1' * 5)
      credit_card.valid?
      credit_card.errors[:cvv].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
      credit_card.valid?
      credit_card.errors[:cvv].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cvv => '1111')
      credit_card.valid?
      credit_card.errors[:cvv].must_be :blank?
    end

    it 'should validate length of cardholder_name' do
      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f' * 256)
      credit_card.valid?
      credit_card.errors[:cardholder_name].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f')
      credit_card.valid?
      credit_card.errors[:cardholder_name].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f' * 255)
      credit_card.valid?
      credit_card.errors[:cardholder_name].must_be :blank?
    end

    it 'should validate expiration month' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      credit_card.errors[:expiration_month].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_month => 0)
      credit_card.valid?
      credit_card.errors[:expiration_month].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_month => 13)
      credit_card.valid?
      credit_card.errors[:expiration_month].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_month => 1)
      credit_card.valid?
      credit_card.errors[:expiration_month].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_month => '12')
      credit_card.valid?
      credit_card.errors[:expiration_month].must_be :blank?
    end

    it 'should validate expiration year' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      credit_card.errors[:expiration_year].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_year => 1975)
      credit_card.valid?
      credit_card.errors[:expiration_year].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_year => 2201)
      credit_card.valid?
      credit_card.errors[:expiration_year].wont_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_year => 1976)
      credit_card.valid?
      credit_card.errors[:expiration_year].must_be :blank?

      credit_card = BraintreeRails::CreditCard.new(:expiration_year => '2200')
      credit_card.valid?
      credit_card.errors[:expiration_year].must_be :blank?
    end

    it 'should validate billing_address' do
      credit_card = BraintreeRails::CreditCard.new(:billing_address => OpenStruct.new(:valid? => false))
      credit_card.valid?
      credit_card.errors[:billing_address].wont_be :blank?

      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')
      credit_card = BraintreeRails::CreditCard.new(:billing_address => braintree_credit_card.billing_address)
      credit_card.valid?
      credit_card.errors[:billing_address].must_be :blank?
    end
  end

  describe 'persistence' do
    it 'should add validation errors returned from Braintree' do
      stub_braintree_request(:put, '/payment_methods/credit_card_id', :status => 422, :body => fixture('credit_card_validation_error.xml'))
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      credit_card.update_attributes(:number => '4111111111111111', :cvv => '111')
      credit_card.errors[:number].wont_be :blank?

      credit_card.billing_address.errors[:street_address].wont_be :blank?
      credit_card.billing_address.errors[:postal_code].wont_be :blank?
    end
  end

  describe 'class methods' do
    it "should wrap Braintree's Model find" do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      credit_card.id.must_equal 'credit_card_id'
      credit_card.persisted?.must_equal true
    end

    it "should delegate delete to Braintree's Model" do
      stub_braintree_request(:delete, '/payment_methods/credit_card_id', :body => fixture('credit_card.xml'))
      BraintreeRails::CreditCard.delete('credit_card_id').must_equal true
    end
  end
end
