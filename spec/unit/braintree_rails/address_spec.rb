require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Address do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    end

    it 'should wrap a Braintree::Address' do
      braintree_address = Braintree::Customer.find('customer_id').addresses.first
      address = BraintreeRails::Address.new(braintree_address)

      expect(address).to be_persisted
      BraintreeRails::Address.attributes.each do |attribute|
        expect(address.send(attribute)).to eq(braintree_address.send(attribute))
      end
    end

    it 'should find a Braintree::Address' do
      stub_braintree_request(:get, '/customers/customer_id/addresses/address_id', :body => fixture('address.xml'))
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_address = braintree_customer.addresses.first
      address = BraintreeRails::Address.find('customer_id', braintree_address.id)

      expect(address).to be_persisted
      BraintreeRails::Address.attributes.each do |attribute|
        expect(address.send(attribute)).to eq(braintree_address.send(attribute))
      end
    end

    it 'should extract values from hash' do
      address = BraintreeRails::Address.new(:id => 'new_id')

      expect(address).to_not be_persisted
      expect(address.id).to eq('new_id')
    end

    it 'should try to extract value from other types' do
      address = BraintreeRails::Address.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      expect(address).to be_persisted
      expect(address.id).to eq('foobar')
      expect(address.first_name).to eq('Foo')
      expect(address.last_name).to eq('Bar')

      address = BraintreeRails::Address.new(Object.new)
      expect(address).to_not be_persisted
    end
  end

  describe 'country_name' do
    it 'should auto set country_name' do
      {:country_code_alpha2 => 'US', :country_code_alpha3 => 'USA', :country_code_numeric => '840'}.each_pair do |key, value|
        address = BraintreeRails::Address.new(key => value)
        expect(address.country_name).to eq('United States of America')
      end
    end
  end

  describe 'customer' do
    it 'should load customer for persisted address' do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
      address = BraintreeRails::Customer.new('customer_id').addresses.first
      expect(address.customer).to be_persisted
      expect(address.customer.id).to eq('customer_id')
    end
  end

  describe 'full_name' do
    it 'should combine first_name and last_name to form full_name' do
      expect(BraintreeRails::Address.new(:first_name => "Foo", :last_name => 'Bar').full_name).to eq("Foo Bar")
    end

    it 'should not have extra spaces when first_name or last_name is missing' do
      expect(BraintreeRails::Address.new(:first_name => "Foo").full_name).to eq('Foo')
      expect(BraintreeRails::Address.new(:last_name => 'Bar').full_name).to eq('Bar')
    end
  end

  describe 'validations' do
    [:first_name, :last_name, :company, :street_address, :extended_address, :locality, :region].each do |attribute|
      it "should validate length of #{attribute}" do
        address = BraintreeRails::Address.new(attribute => 'f')
        address.valid?
        expect(address.errors[attribute]).to be_blank

        address = BraintreeRails::Address.new(attribute => 'f' * 255)
        address.valid?
        expect(address.errors[attribute]).to be_blank

        address = BraintreeRails::Address.new(attribute => 'foo' * 256)
        address.valid?
        expect(address.errors[attribute]).to_not be_blank
      end
    end

    [:street_address, :postal_code].each do |attribute|
      it "should validate presence of #{attribute}" do
        address = BraintreeRails::Address.new(attribute => 'foo')
        address.valid?
        expect(address.errors[attribute]).to be_blank

        address = BraintreeRails::Address.new
        address.valid?
        expect(address.errors[attribute]).to_not be_blank
      end
    end

    it 'should validate format of postal_code' do
      address = BraintreeRails::Address.new({:postal_code => 'CA 94025'})
      address.valid?
      expect(address.errors[:postal_code]).to be_blank

      address = BraintreeRails::Address.new({:postal_code => '%$'})
      address.valid?
      expect(address.errors[:postal_code]).to_not be_blank
    end
  end

  [BraintreeRails::BillingAddress, BraintreeRails::ShippingAddress].each do |subclass|
    describe subclass do
      it 'should have braintree_model_class to be Braintree::Address' do
        expect(subclass.braintree_model_class).to eq(Braintree::Address)
      end
    end
  end
end
