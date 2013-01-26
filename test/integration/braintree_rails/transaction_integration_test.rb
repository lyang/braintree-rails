require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Transaction Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to create, submit, void transactions for a customer' do

    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)

    transaction = BraintreeRails::Transaction.create!(:customer => customer, :amount => rand(1..5))
    transaction.persisted?.must_equal true
    transaction.status.must_equal Braintree::Transaction::Status::Authorized

    transaction.submit_for_settlement!
    transaction.status.must_equal Braintree::Transaction::Status::SubmittedForSettlement

    transaction.void!
    transaction.status.must_equal Braintree::Transaction::Status::Voided
  end

  it 'should be able to create, submit, void transactions for a customer with a credit_card' do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first

    transaction = BraintreeRails::Transaction.create!(:customer => customer, :amount => rand(1..5), :credit_card => credit_card)
    transaction.persisted?.must_equal true
    transaction.status.must_equal Braintree::Transaction::Status::Authorized

    transaction.submit_for_settlement!
    transaction.status.must_equal Braintree::Transaction::Status::SubmittedForSettlement

    transaction.void!
    transaction.status.must_equal Braintree::Transaction::Status::Voided
  end


  it "should be able to load transactions for given customer and credit_card" do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first
    transaction = BraintreeRails::Transaction.create!(:amount => rand(1..10), :customer => customer)

    customer.transactions.length.must_equal 1
    customer.transactions.each do |t|
     t.must_equal transaction
    end
    credit_card.transactions.count.must_equal 1
  end

  it 'should be able to create a one time transaction' do
    transaction = BraintreeRails::Transaction.create!(:amount => rand(1..10), :customer => customer_hash, :credit_card => credit_card_hash)
    transaction.persisted?.must_equal true
    transaction.id.wont_be :blank?
  end

  it 'should be able to capture braintree api errors' do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first
    transaction = BraintreeRails::Transaction.create!(:amount => rand(1..10), :customer => customer)

    transaction.void!
    transaction.submit_for_settlement.must_equal false
    transaction.errors[:base].wont_be :blank?

    lambda{transaction.submit_for_settlement!}.must_raise Braintree::ValidationsFailed
  end

  describe BraintreeRails::Transactions do
    describe '#default_options' do
      it 'should use default options to build new record' do
        braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
        customer = BraintreeRails::Customer.new(braintree_customer)
        credit_card = customer.credit_cards.first

        transaction = BraintreeRails::Transactions.new(customer, credit_card).build({})
        transaction.customer.must_equal customer
        transaction.credit_card.must_equal credit_card
      end
    end
  end
end
