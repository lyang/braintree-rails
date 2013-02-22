require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Plan do
  describe '#initialize' do
    before do
      stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
    end

    it 'should wrap a Braintree::Plan' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.new(braintree_plan)

      plan.persisted?.must_equal true
      BraintreeRails::Plan.attributes.each do |attribute|
        plan.send(attribute).must_equal braintree_plan.send(attribute)
      end
    end

    it 'should find a Braintree::Plan' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.find('plan_id')

      plan.persisted?.must_equal true
      BraintreeRails::Plan.attributes.each do |attribute|
        plan.send(attribute).must_equal braintree_plan.send(attribute)
      end
    end
  end
end
