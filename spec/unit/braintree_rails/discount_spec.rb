require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Discount do
  before do
    stub_braintree_request(:get, '/discounts', :body => fixture('discounts.xml'))
  end

  describe '#initialize' do
    it 'should wrap a Braintree::Discount' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.new(braintree_discount)

      expect(discount).to be_persisted
      expect(discount.never_expires?).to eq(braintree_discount.never_expires?)
      BraintreeRails::Discount.attributes.each do |attribute|
        expect(discount.send(attribute)).to eq(braintree_discount.send(attribute))
      end
    end

    it 'should load a Braintree::Discount by id' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.new('discount_id')

      expect(discount).to be_persisted
      BraintreeRails::Discount.attributes.each do |attribute|
        expect(discount.send(attribute)).to eq(braintree_discount.send(attribute))
      end
    end

    it 'should find a Braintree::Discount' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.find('discount_id')

      expect(discount).to be_persisted
      BraintreeRails::Discount.attributes.each do |attribute|
        expect(discount.send(attribute)).to eq(braintree_discount.send(attribute))
      end
    end
  end

  describe 'all' do
    it 'should wrap all discounts' do
      braintree_discounts = Braintree::Discount.all
      discounts = BraintreeRails::Discount.all

      expect(discounts).to respond_to(:each)
      expect(discounts.size).to eq(braintree_discounts.size)
    end
  end
end

