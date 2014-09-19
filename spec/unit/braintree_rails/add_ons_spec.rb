require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::AddOns do
  before do
    stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::AddOn' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      braintree_add_ons = braintree_plan.add_ons
      add_ons = BraintreeRails::AddOns.new(BraintreeRails::Plan.find('plan_id'))

      expect(add_ons.size).to eq(braintree_add_ons.size)

      braintree_add_ons.each do |braintree_add_on|
        add_on = add_ons.find(braintree_add_on.id)
        BraintreeRails::AddOn.attributes.each do |attribute|
          expect(add_on.send(attribute)).to eq(braintree_add_on.send(attribute))
        end
      end
    end
  end

  describe '#create' do
    it 'should throw NotSupportedApiException' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      braintree_add_ons = braintree_plan.add_ons
      add_ons = BraintreeRails::AddOns.new(BraintreeRails::Plan.find('plan_id'))
      expect { add_ons.create }.to raise_error(BraintreeRails::NotSupportedApiException)
    end
  end
end
