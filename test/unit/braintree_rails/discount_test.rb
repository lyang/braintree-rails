require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Discount do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/discounts', :body => fixture('discounts.xml'))
    end

    it 'should wrap a Braintree::Discount' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.new(braintree_discount)

      discount.persisted?.must_equal true
      BraintreeRails::Discount.attributes.each do |attribute|
        discount.send(attribute).must_equal braintree_discount.send(attribute)
      end
    end

    it 'should load a Braintree::Discount by id' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.new('discount_id')

      discount.persisted?.must_equal true
      BraintreeRails::Discount.attributes.each do |attribute|
        discount.send(attribute).must_equal braintree_discount.send(attribute)
      end
    end

    it 'should find a Braintree::Discount' do
      braintree_discount = Braintree::Discount.all.find { |d| d.id == 'discount_id' }
      discount = BraintreeRails::Discount.find('discount_id')

      discount.persisted?.must_equal true
      BraintreeRails::Discount.attributes.each do |attribute|
        discount.send(attribute).must_equal braintree_discount.send(attribute)
      end
    end
  end
end

