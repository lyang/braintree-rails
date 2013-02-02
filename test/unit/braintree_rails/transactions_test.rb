require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Transactions do

  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should load an array of Braintree::Transaction' do
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))

      braintree_transactions = Braintree::Transaction.search do |search|
        search.customer_id.is 'customer_id'
        search.payment_method_token.is 'credit_card_id'
      end

      transactions = BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))

      transactions.map(&:id).sort.must_equal braintree_transactions.map(&:id).sort
    end
  end

  describe '#lazy_loading' do
    it 'should not load if not necessary' do
      lambda {BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))}.must_be_silent
    end

    it 'load from Braintree when needed' do
      transactions = BraintreeRails::Transactions.new(BraintreeRails::Customer.new('customer_id'))
      stub_braintree_request(:post, '/transactions/advanced_search_ids', :body => fixture('transaction_ids.xml'))
      stub_braintree_request(:post, '/transactions/advanced_search', :body => fixture('transactions.xml'))

      transactions.find('transactionid').wont_be :blank?
    end
  end
end
