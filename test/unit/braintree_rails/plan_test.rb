require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Plan do
  before do
    stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
  end

  describe '#initialize' do
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

  describe '#add_ons' do
    it 'behaves like enumerable' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.new(braintree_plan)

      plan.add_ons.must_be_kind_of(Enumerable)
      plan.add_ons.size.must_equal braintree_plan.add_ons.size
    end
  end
end
