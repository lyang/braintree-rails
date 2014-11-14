require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Discounts do
  before do
    stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::Discount' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      braintree_discounts = braintree_plan.discounts
      discounts = BraintreeRails::Discounts.new(BraintreeRails::Plan.find('plan_id'))

      expect(discounts.size).to eq(braintree_discounts.size)

      braintree_discounts.each do |braintree_discount|
        discount = discounts.find(braintree_discount.id)
        BraintreeRails::Discount.attributes.each do |attribute|
          expect(discount.send(attribute)).to eq(braintree_discount.send(attribute))
        end
      end
    end
  end

  describe '#create' do
    it 'should throw NotSupportedApiException' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      braintree_discounts = braintree_plan.discounts
      discounts = BraintreeRails::Discounts.new(BraintreeRails::Plan.find('plan_id'))
      expect { discounts.create }.to raise_error(BraintreeRails::NotSupportedApiException)
    end
  end
end