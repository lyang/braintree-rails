require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Transaction Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to create, submit, void transactions for a customer' do

    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first

    [{:amount => 10.00, :customer => customer}, {:amount => 20.00, :customer => customer, :credit_card => credit_card}].each do |params|
      transaction = BraintreeRails::Transaction.create!(params)
      transaction.persisted?.must_equal true
      transaction.amount.must_equal params[:amount]
      transaction.status.must_equal Braintree::Transaction::Status::Authorized

      transaction.submit_for_settlement!
      transaction.status.must_equal Braintree::Transaction::Status::SubmittedForSettlement

      transaction.void!
      transaction.status.must_equal Braintree::Transaction::Status::Voided
    end
  end

  it "should be able to load transactions for given customer and credit_card" do
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first
    transaction = BraintreeRails::Transaction.create!({:amount => 15.00, :customer => customer})
    
    customer.transactions.count.must_equal 1
    credit_card.transactions.count.must_equal 1
  end
end