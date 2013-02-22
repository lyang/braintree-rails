require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::AddOn do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/add_ons', :body => fixture('add_ons.xml'))
    end

    it 'should wrap a Braintree::AddOn' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.new(braintree_add_on)

      add_on.persisted?.must_equal true
      BraintreeRails::AddOn.attributes.each do |attribute|
        add_on.send(attribute).must_equal braintree_add_on.send(attribute)
      end
    end

    it 'should load a Braintree::AddOn by id' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.new('add_on_id')

      add_on.persisted?.must_equal true
      BraintreeRails::AddOn.attributes.each do |attribute|
        add_on.send(attribute).must_equal braintree_add_on.send(attribute)
      end
    end

    it 'should find a Braintree::AddOn' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.find('add_on_id')

      add_on.persisted?.must_equal true
      BraintreeRails::AddOn.attributes.each do |attribute|
        add_on.send(attribute).must_equal braintree_add_on.send(attribute)
      end
    end
  end
end

