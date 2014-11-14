require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Plan do
  before do
    stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
  end

  describe '#initialize' do
    it 'should wrap a Braintree::Plan' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.new(braintree_plan)

      expect(plan).to be_persisted
      BraintreeRails::Plan.attributes.each do |attribute|
        expect(plan.send(attribute)).to eq(braintree_plan.send(attribute))
      end
    end

    it 'should find a Braintree::Plan' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.find('plan_id')

      expect(plan).to be_persisted
      BraintreeRails::Plan.attributes.each do |attribute|
        expect(plan.send(attribute)).to eq(braintree_plan.send(attribute))
      end
    end
  end

  describe 'all' do
    it 'should wrap all plans' do
      braintree_plans = Braintree::Plan.all
      plans = BraintreeRails::Plan.all

      expect(plans).to respond_to(:each)
      expect(plans.size).to eq(braintree_plans.size)
    end
  end

  [:add_ons, :discounts].each do |association|
    describe association do
      it 'behaves like enumerable' do
        braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
        plan = BraintreeRails::Plan.new(braintree_plan)

        expect(plan.send(association)).to respond_to(:each)
        expect(plan.send(association).size).to eq(braintree_plan.send(association).size)
      end
    end
  end

  describe 'subscriptions' do
    before do
      stub_braintree_request(:post, '/subscriptions/advanced_search_ids', :body => fixture('subscription_ids.xml'))
      stub_braintree_request(:post, '/subscriptions/advanced_search', :body => fixture('subscriptions.xml'))
    end

    it 'behaves like enumerable' do
      braintree_plan = Braintree::Plan.all.find { |p| p.id == 'plan_id' }
      plan = BraintreeRails::Plan.new(braintree_plan)
      braintree_subscriptions = Braintree::Subscription.search do |search|
        search.plan_id.is 'plan_id'
      end.to_a

      expect(plan.subscriptions).to respond_to(:each)
      expect(plan.subscriptions.size).to eq(braintree_subscriptions.size)
    end

    it 'can build new subscription' do
      plan = BraintreeRails::Plan.new('plan_id')
      subscription = plan.subscriptions.build
      expect(subscription.plan_id).to eq(plan.id)
    end
  end
end