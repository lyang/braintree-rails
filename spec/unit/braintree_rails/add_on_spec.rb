require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::AddOn do
  before do
    stub_braintree_request(:get, '/add_ons', :body => fixture('add_ons.xml'))
  end

  describe '#initialize' do
    it 'should wrap a Braintree::AddOn' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.new(braintree_add_on)

      expect(add_on).to be_persisted
      expect(add_on.never_expires?).to eq(braintree_add_on.never_expires?)
      BraintreeRails::AddOn.attributes.each do |attribute|
        expect(add_on.send(attribute)).to eq(braintree_add_on.send(attribute))
      end
    end

    it 'should load a Braintree::AddOn by id' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.new('add_on_id')

      expect(add_on).to be_persisted
      BraintreeRails::AddOn.attributes.each do |attribute|
        expect(add_on.send(attribute)).to eq(braintree_add_on.send(attribute))
      end
    end

    it 'should find a Braintree::AddOn' do
      braintree_add_on = Braintree::AddOn.all.find { |a| a.id == 'add_on_id' }
      add_on = BraintreeRails::AddOn.find('add_on_id')

      expect(add_on).to be_persisted
      BraintreeRails::AddOn.attributes.each do |attribute|
        expect(add_on.send(attribute)).to eq(braintree_add_on.send(attribute))
      end
    end
  end

  describe 'all' do
    it 'should wrap all add_ons' do
      braintree_add_ons = Braintree::AddOn.all
      add_ons = BraintreeRails::AddOn.all

      expect(add_ons).to respond_to(:each)
      expect(add_ons.size).to eq(braintree_add_ons.size)
    end
  end
end

