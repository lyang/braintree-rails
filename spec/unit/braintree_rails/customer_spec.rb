require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Customer do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should find customer from braintree when given a customer id' do
      customer = BraintreeRails::Customer.new('customer_id')
      braintree_customer = Braintree::Customer.find('customer_id')

      expect(customer).to be_persisted
      BraintreeRails::Customer.attributes.each do |attribute|
        expect(customer.send(attribute)).to eq(braintree_customer.send(attribute)) if braintree_customer.respond_to?(attribute)
      end
    end

    it 'should wrap a Braintree::Customer' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      expect(customer).to be_persisted
      BraintreeRails::Customer.attributes.each do |attribute|
        expect(customer.send(attribute)).to eq(braintree_customer.send(attribute)) if braintree_customer.respond_to?(attribute)
      end
    end

    it 'should extract values from hash' do
      customer = BraintreeRails::Customer.new(:id => 'new_id')

      expect(customer).to_not be_persisted
      expect(customer.id).to eq('new_id')
    end

    it 'should try to extract value from other types' do
      customer = BraintreeRails::Customer.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      expect(customer).to be_persisted
      expect(customer.id).to eq('foobar')
      expect(customer.first_name).to eq('Foo')
      expect(customer.last_name).to eq('Bar')

      customer = BraintreeRails::Customer.new(OpenStruct.new)
      expect(customer).to_not be_persisted
    end
  end

  describe '#addresses' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      expect(customer.addresses).to respond_to(:each)
      expect(customer.addresses.size).to eq(braintree_customer.addresses.size)
    end
  end

  describe '#credit_cards' do
    it 'behaves like enumerable' do
      braintree_customer = Braintree::Customer.find('customer_id')
      customer = BraintreeRails::Customer.new(braintree_customer)

      expect(customer.credit_cards).to respond_to(:each)
      expect(customer.credit_cards.size).to eq(braintree_customer.credit_cards.size)
    end
  end

  describe '#full_name' do
    it 'should combine first_name and last_name to form full_name' do
      expect(BraintreeRails::Customer.new(:first_name => "Foo", :last_name => 'Bar').full_name).to eq("Foo Bar")
    end

    it 'should not have extra spaces when first_name or last_name is missing' do
      expect(BraintreeRails::Customer.new(:first_name => "Foo").full_name).to eq('Foo')
      expect(BraintreeRails::Customer.new(:last_name => 'Bar').full_name).to eq('Bar')
    end
  end

  describe 'validations' do
    it 'should validate id' do
      customer = BraintreeRails::Customer.new(:id => '%')
      customer.valid?
      expect(customer.errors[:id]).to_not be_blank

      customer = BraintreeRails::Customer.new(:id => 'all')
      customer.valid?
      expect(customer.errors[:id]).to_not be_blank

      customer = BraintreeRails::Customer.new(:id => 'new')
      customer.valid?
      expect(customer.errors[:id]).to_not be_blank

      customer = BraintreeRails::Customer.new(:id => 'f' * 37)
      customer.valid?
      expect(customer.errors[:id]).to_not be_blank

      customer = BraintreeRails::Customer.new
      customer.valid?
      expect(customer.errors[:id]).to be_blank

      customer = BraintreeRails::Customer.new(:id => 'f')
      customer.valid?
      expect(customer.errors[:id]).to be_blank

      customer = BraintreeRails::Customer.new(:id => 'f' * 36)
      customer.valid?
      expect(customer.errors[:id]).to be_blank
    end

    [:first_name, :last_name, :company, :website, :phone, :fax].each do |attribute|
      it "should validate length of #{attribute}" do
        customer = BraintreeRails::Customer.new(attribute => 'f')
        customer.valid?
        expect(customer.errors[attribute]).to be_blank

        customer = BraintreeRails::Customer.new(attribute => 'f' * 255)
        customer.valid?
        expect(customer.errors[attribute]).to be_blank

        customer = BraintreeRails::Customer.new(attribute => 'foo' * 256)
        customer.valid?
        expect(customer.errors[attribute]).to_not be_blank
      end
    end

    describe 'credit_card' do
      it 'is valid if new credit card is valid' do
        customer = BraintreeRails::Customer.new(:credit_card => credit_card_hash)
        expect(customer).to be_valid
      end

      it 'is not valid if new credit card is invalid' do
        customer = BraintreeRails::Customer.new(:credit_card => credit_card_hash.except(:number))
        expect(customer).to_not be_valid
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
        customer = BraintreeRails::Customer.new
        expect(customer.save).to eq(true)
        expect(customer).to be_persisted
      end

      it 'should not throw error when not valid' do
        customer = BraintreeRails::Customer.new(:first_name => 'f' * 256)
        expect(customer.save).to eq(false)
        expect(customer).to_not be_persisted
      end

      it 'should return true when saved with bang' do
        customer = BraintreeRails::Customer.new
        expect(customer.save!).to eq(true)
        expect(customer).to be_persisted
      end

      it 'should throw error when save invalid record with bang' do
        customer = BraintreeRails::Customer.new(:first_name => 'f' * 256)
        expect { customer.save! }.to raise_error(BraintreeRails::RecordInvalid)
        expect(customer).to_not be_persisted
      end
    end

    describe 'update_attributes, update_attributes!' do
      it 'should return true when update_attributes' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        expect(customer.update_attributes(:first_name => 'f')).to eq(true)
      end

      it 'should not throw error when not valid' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        expect(customer.update_attributes(:first_name => 'f' * 256)).to eq(false)
      end

      it 'should return true when update_attributesd with bang' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        expect(customer.update_attributes!(:first_name => 'f')).to eq(true)
      end

      it 'should throw error when update_attributes invalid record with bang' do
        customer = BraintreeRails::Customer.new(Braintree::Customer.find('customer_id'))
        expect { customer.update_attributes!(:first_name => 'f' * 256) }.to raise_error(BraintreeRails::RecordInvalid)
      end
    end

    describe 'serialization' do
      it 'can be serializable hash' do
        customer = BraintreeRails::Customer.new('customer_id')
        expect(customer.serializable_hash).to be_kind_of(Hash)
      end

      it 'can be serialized to xml' do
        customer = BraintreeRails::Customer.new('customer_id')
        expect(customer.to_xml).to include "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      end

      it 'can be serialized to json' do
        customer = BraintreeRails::Customer.new('customer_id')
        expect(customer.as_json).to be_kind_of(Hash)
      end
    end
  end
end
