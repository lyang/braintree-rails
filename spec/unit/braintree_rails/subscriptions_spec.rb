require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Subscriptions do

  before do
    stub_braintree_request(:get, '/plans', :body => fixture('plans.xml'))
    stub_braintree_request(:post, '/subscriptions/advanced_search_ids', :body => fixture('subscription_ids.xml'))
    stub_braintree_request(:post, '/subscriptions/advanced_search', :body => fixture('subscriptions.xml'))
  end

  describe '#initialize' do
    it 'should load an array of Braintree::Subscription for given plan' do
      braintree_subscriptions = Braintree::Subscription.search do |search|
        search.plan_id.is 'plan_id'
      end

      subscriptions = BraintreeRails::Subscriptions.new(BraintreeRails::Plan.new('plan_id'))

      expect(subscriptions.map(&:id).sort).to eq(braintree_subscriptions.map(&:id).sort)
    end

    it 'should load all subscriptions' do
      stub_braintree_request(:post, '/subscriptions/advanced_search_ids', :body => fixture('subscription_ids.xml'))
      stub_braintree_request(:post, '/subscriptions/advanced_search', :body => fixture('subscriptions.xml'))

      braintree_subscriptions = Braintree::Subscription.search
      subscriptions = BraintreeRails::Subscriptions.new(nil)
      expect(subscriptions.map(&:id).sort).to eq(braintree_subscriptions.map(&:id).sort)
    end
  end

  describe '#build' do
    it 'has no default options when loading all' do
      subscriptions = BraintreeRails::Subscriptions.new(nil)
      subscription = subscriptions.build
      expect(subscription.attributes.values.compact).to be_empty
    end
  end
end

