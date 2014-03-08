require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Address do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    end

    it 'should wrap a Braintree::Address' do
      braintree_address = Braintree::Customer.find('customer_id').addresses.first
      address = BraintreeRails::Address.new(braintree_address)

      address.should be_persisted
      BraintreeRails::Address.attributes.each do |attribute|
        address.send(attribute).should == braintree_address.send(attribute)
      end
    end

    it 'should find a Braintree::Address' do
      stub_braintree_request(:get, '/customers/customer_id/addresses/address_id', :body => fixture('address.xml'))
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_address = braintree_customer.addresses.first
      address = BraintreeRails::Address.find('customer_id', braintree_address.id)

      address.should be_persisted
      BraintreeRails::Address.attributes.each do |attribute|
        address.send(attribute).should == braintree_address.send(attribute)
      end
    end

    it 'should extract values from hash' do
      address = BraintreeRails::Address.new(:id => 'new_id')

      address.should_not be_persisted
      address.id.should == 'new_id'
    end

    it 'should try to extract value from other types' do
      address = BraintreeRails::Address.new(OpenStruct.new(:id => 'foobar', :first_name => 'Foo', :last_name => 'Bar', :persisted? => true))

      address.should be_persisted
      address.id.should == 'foobar'
      address.first_name.should == 'Foo'
      address.last_name.should == 'Bar'

      address = BraintreeRails::Address.new(Object.new)
      address.should_not be_persisted
    end
  end

  describe 'country_name' do
    it 'should auto set country_name' do
      {:country_code_alpha2 => 'US', :country_code_alpha3 => 'USA', :country_code_numeric => '840'}.each_pair do |key, value|
        address = BraintreeRails::Address.new(key => value)
        address.country_name.should == 'United States of America'
      end
    end
  end

  describe 'customer' do
    it 'should load customer for persisted address' do
      stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
      address = BraintreeRails::Customer.new('customer_id').addresses.first
      address.customer.should be_persisted
      address.customer.id.should == 'customer_id'
    end
  end

  describe 'full_name' do
    it 'should combine first_name and last_name to form full_name' do
      BraintreeRails::Address.new(:first_name => "Foo", :last_name => 'Bar').full_name.should == "Foo Bar"
    end

    it 'should not have extra spaces when first_name or last_name is missing' do
      BraintreeRails::Address.new(:first_name => "Foo").full_name.should == 'Foo'
      BraintreeRails::Address.new(:last_name => 'Bar').full_name.should == 'Bar'
    end
  end

  describe 'validations' do
    [:first_name, :last_name, :company, :street_address, :extended_address, :locality, :region].each do |attribute|
      it "should validate length of #{attribute}" do
        address = BraintreeRails::Address.new(attribute => 'f')
        address.valid?
        address.errors[attribute].should be_blank

        address = BraintreeRails::Address.new(attribute => 'f' * 255)
        address.valid?
        address.errors[attribute].should be_blank

        address = BraintreeRails::Address.new(attribute => 'foo' * 256)
        address.valid?
        address.errors[attribute].should_not be_blank
      end
    end

    [:street_address, :postal_code].each do |attribute|
      it "should validate presence of #{attribute}" do
        address = BraintreeRails::Address.new(attribute => 'foo')
        address.valid?
        address.errors[attribute].should be_blank

        address = BraintreeRails::Address.new
        address.valid?
        address.errors[attribute].should_not be_blank
      end
    end

    it 'should validate format of postal_code' do
      address = BraintreeRails::Address.new({:postal_code => 'CA 94025'})
      address.valid?
      address.errors[:postal_code].should be_blank

      address = BraintreeRails::Address.new({:postal_code => '%$'})
      address.valid?
      address.errors[:postal_code].should_not be_blank
    end
  end

  [BraintreeRails::BillingAddress, BraintreeRails::ShippingAddress].each do |subclass|
    describe subclass do
      it 'should have braintree_model_class to be Braintree::Address' do
        subclass.braintree_model_class.should == Braintree::Address
      end
    end
  end
end
