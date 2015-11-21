require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::CreditCard do
  before do
    stub_braintree_request(:get, '/payment_methods/credit_card/credit_card_id', :body => fixture('credit_card.xml'))
  end

  describe '#initialize' do
    it 'should find credit_card from braintree when given a credit_card id' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')

      expect(credit_card).to be_persisted
      expect(credit_card.default?).to eq(braintree_credit_card.default?)
      expect(credit_card.expired?).to eq(braintree_credit_card.expired?)
      expect(credit_card.masked_number).to eq(braintree_credit_card.masked_number)
      expect(credit_card.image_url).to eq(braintree_credit_card.image_url)
      BraintreeRails::CreditCard.attributes.each do |attribute|
        next if BraintreeRails::CreditCard.associations.include?(attribute)
        if braintree_credit_card.respond_to?(attribute)
          expect(braintree_credit_card.send(attribute)).to eq(credit_card.send(attribute))
        end
      end
    end

    it 'should wrap a Braintree::CreditCard' do
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')
      credit_card = BraintreeRails::CreditCard.new(braintree_credit_card)

      expect(credit_card).to be_persisted
      BraintreeRails::CreditCard.attributes.each do |attribute|
        next if BraintreeRails::CreditCard.associations.include?(attribute)
        if braintree_credit_card.respond_to?(attribute)
          expect(braintree_credit_card.send(attribute)).to eq(credit_card.send(attribute))
        end
      end
    end

    it 'should extract values from hash' do
      credit_card = BraintreeRails::CreditCard.new(:token => 'new_id')

      expect(credit_card).to_not be_persisted
      expect(credit_card.token).to eq('new_id')
    end

    it 'should try to extract value from other types' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:token => 'foobar', :cardholder_name => 'Foo Bar', :persisted? => true))

      expect(credit_card).to be_persisted
      expect(credit_card.token).to eq('foobar')
      expect(credit_card.cardholder_name).to eq('Foo Bar')

      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new)
      expect(credit_card).to_not be_persisted
    end
  end

  describe 'customer' do
    it 'should load customer for persisted credit_card' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
      expect(credit_card.customer).to be_persisted
      expect(credit_card.customer.id).to eq('customer_id')
    end
  end

  describe "#subscriptions" do
    it 'behaves like enumerable' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')

      expect(credit_card.subscriptions).to respond_to(:each)
      expect(credit_card.subscriptions.size).to eq(braintree_credit_card.subscriptions.size)
    end

    it 'can build new subscription' do
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      subscription = credit_card.subscriptions.build
      expect(subscription.payment_method_token).to eq(credit_card.token)
    end
  end

  describe '#billing_address' do
    it 'should wrap billing_address with Address object' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:billing_address => {}))
      expect(credit_card.billing_address.class.ancestors).to include BraintreeRails::Address

      credit_card.billing_address = BraintreeRails::Address.new
      expect(credit_card.billing_address.class.ancestors).to include(BraintreeRails::Address)
    end

    it 'should keep billing_address nil if assigned nil value' do
      credit_card = BraintreeRails::CreditCard.new(OpenStruct.new(:billing_address => nil))
      expect(credit_card.billing_address).to be_nil
    end

  end

  describe 'validations' do
    it 'should validate precence of customer_id on create' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?(:create)
      expect(credit_card.errors[:customer_id]).to_not be_blank

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo')
      credit_card.valid?(:create)
      expect(credit_card.errors[:customer_id]).to be_blank
    end

    it 'should validate length of customer_id' do
      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo' * 13)
      credit_card.valid?(:create)
      expect(credit_card.errors[:customer_id]).to_not be_blank

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo')
      credit_card.valid?(:create)
      expect(credit_card.errors[:customer_id]).to be_blank

      credit_card = BraintreeRails::CreditCard.new(:customer_id => 'foo' * 12)
      credit_card.valid?(:create)
      expect(credit_card.errors[:customer_id]).to be_blank
    end

    it 'should validate precence of number if new_record?' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      expect(credit_card.errors[:number]).to_not be_blank

      credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
      credit_card.valid?
      expect(credit_card.errors[:number]).to be_blank

      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      expect(credit_card).to be_valid
    end

    it 'should validate precence of cvv' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      expect(credit_card.errors[:cvv]).to_not be_blank

      credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
      credit_card.valid?
      expect(credit_card.errors[:cvv]).to be_blank
    end

    describe 'S2S mode' do
      before do
        BraintreeRails::Configuration.mode = BraintreeRails::Configuration::Mode::S2S
      end

      after do
        BraintreeRails::Configuration.mode = BraintreeRails::Configuration::Mode::JS
      end

      it 'should validate numericality of number' do
        credit_card = BraintreeRails::CreditCard.new(:number => 'foobar')
        credit_card.valid?
        expect(credit_card.errors[:number]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
        credit_card.valid?
        expect(credit_card.errors[:number]).to be_blank
      end

      it 'should validate length of number' do
        credit_card = BraintreeRails::CreditCard.new(:number => '1')
        credit_card.valid?
        expect(credit_card.errors[:number]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:number => '1' * 20)
        credit_card.valid?
        expect(credit_card.errors[:number]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:number => '4111111111111111')
        credit_card.valid?
        expect(credit_card.errors[:number]).to be_blank

        credit_card = BraintreeRails::CreditCard.new(:number => '6208645006512478950')
        credit_card.valid?
        expect(credit_card.errors[:number]).to be_blank
      end

      it 'should validate numericality of cvv' do
        credit_card = BraintreeRails::CreditCard.new(:cvv => 'foo')
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to be_blank
      end

      it 'should validate length of cvv' do
        credit_card = BraintreeRails::CreditCard.new(:cvv => '1')
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:cvv => '1' * 5)
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:cvv => '111')
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to be_blank

        credit_card = BraintreeRails::CreditCard.new(:cvv => '1111')
        credit_card.valid?
        expect(credit_card.errors[:cvv]).to be_blank
      end

      it 'should validate expiration month' do
        credit_card = BraintreeRails::CreditCard.new(:expiration_month => 0)
        credit_card.valid?
        expect(credit_card.errors[:expiration_month]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_month => 13)
        credit_card.valid?
        expect(credit_card.errors[:expiration_month]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_month => 1.1)
        credit_card.valid?
        expect(credit_card.errors[:expiration_month]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_month => 1)
        credit_card.valid?
        expect(credit_card.errors[:expiration_month]).to be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_month => '12')
        credit_card.valid?
        expect(credit_card.errors[:expiration_month]).to be_blank
      end

      it 'should validate expiration year' do
        credit_card = BraintreeRails::CreditCard.new(:expiration_year => 1975)
        credit_card.valid?
        expect(credit_card.errors[:expiration_year]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_year => 2201)
        credit_card.valid?
        expect(credit_card.errors[:expiration_year]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_year => 1976.1)
        credit_card.valid?
        expect(credit_card.errors[:expiration_year]).to_not be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_year => 1976)
        credit_card.valid?
        expect(credit_card.errors[:expiration_year]).to be_blank

        credit_card = BraintreeRails::CreditCard.new(:expiration_year => '2200')
        credit_card.valid?
        expect(credit_card.errors[:expiration_year]).to be_blank
      end

    end

    it 'should validate presence of expiration month' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      expect(credit_card.errors[:expiration_month]).to_not be_blank
    end

    it 'should validate presence of expiration year' do
      credit_card = BraintreeRails::CreditCard.new
      credit_card.valid?
      expect(credit_card.errors[:expiration_year]).to_not be_blank
    end

    it 'should validate length of cardholder_name' do
      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f' * 256)
      credit_card.valid?
      expect(credit_card.errors[:cardholder_name]).to_not be_blank

      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f')
      credit_card.valid?
      expect(credit_card.errors[:cardholder_name]).to be_blank

      credit_card = BraintreeRails::CreditCard.new(:cardholder_name => 'f' * 255)
      credit_card.valid?
      expect(credit_card.errors[:cardholder_name]).to be_blank
    end

    it 'should validate billing_address' do
      credit_card = BraintreeRails::CreditCard.new(:billing_address => OpenStruct.new(:valid? => false))
      credit_card.valid?
      expect(credit_card.errors[:billing_address]).to_not be_blank

      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')
      credit_card = BraintreeRails::CreditCard.new(:billing_address => braintree_credit_card.billing_address)
      credit_card.valid?
      expect(credit_card.errors[:billing_address]).to be_blank
    end
  end

  describe 'persistence' do
    it 'should add validation errors returned from Braintree' do
      stub_braintree_request(:put, '/payment_methods/credit_card/credit_card_id', :status => 422, :body => fixture('credit_card_validation_error.xml'))
      credit_card = BraintreeRails::CreditCard.new('credit_card_id')
      credit_card.update_attributes(:number => '4111111111111111', :cvv => '111')
      expect(credit_card.errors[:number]).to_not be_blank

      expect(credit_card.billing_address.errors[:street_address]).to_not be_blank
      expect(credit_card.billing_address.errors[:postal_code]).to_not be_blank
    end

    it 'should clear encrypted attributes after save' do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      credit_card.number = "foo"
      stub_braintree_request(:put, '/payment_methods/credit_card/credit_card_id', :body => fixture('credit_card.xml'))
      credit_card.save
      expect(credit_card.number).to be_blank
    end

    it 'should clear encrypted attributes even when save! fails' do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      credit_card.number = "foo"
      stub_braintree_request(:put, '/payment_methods/credit_card/credit_card_id', :status => 422, :body => fixture('credit_card_validation_error.xml'))
      expect {credit_card.save!}.to raise_error(Braintree::ValidationsFailed)
      expect(credit_card.number).to be_blank
    end

    it 'should clear encrypted attributes' do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      credit_card.number = "foo"
      credit_card.clear_encryped_attributes
      expect(credit_card.number).to be_blank
    end

    it 'should update expiration_date when required' do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      attributes = {
        :number => '4111111111111111',
        :cvv => '111',
        :expiration_date => '02/2020',
      }
      credit_card.assign_attributes(attributes)
      expect(credit_card.attributes_for(:update)[:expiration_date]).to eq('02/2020')
    end
  end

  describe 'class methods' do
    it "should wrap Braintree's Model find" do
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      expect(credit_card.id).to eq('credit_card_id')
      expect(credit_card).to be_persisted
    end

    it "should delegate delete to Braintree's Model" do
      stub_braintree_request(:delete, '/payment_methods/credit_card/credit_card_id', :body => fixture('credit_card.xml'))
      expect(BraintreeRails::CreditCard.delete('credit_card_id')).to eq(true)
    end
  end
end
