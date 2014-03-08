require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'Transaction Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to create, submit, void transactions for a customer' do

    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)

    transaction = BraintreeRails::Transaction.create!(:customer => customer, :amount => (1..5).to_a.sample)
    transaction.should be_persisted
    transaction.status.should == Braintree::Transaction::Status::Authorized

    transaction.submit_for_settlement!
    transaction.status.should == Braintree::Transaction::Status::SubmittedForSettlement

    transaction.void!
    transaction.status.should == Braintree::Transaction::Status::Voided
  end

  it 'should be able to create, submit, void transactions for a customer with a credit_card' do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first

    transaction = BraintreeRails::Transaction.create!(:customer => customer, :amount => (1..5).to_a.sample, :credit_card => credit_card)
    transaction.should be_persisted
    transaction.status.should == Braintree::Transaction::Status::Authorized

    transaction.submit_for_settlement!
    transaction.status.should == Braintree::Transaction::Status::SubmittedForSettlement

    transaction.void!
    transaction.status.should == Braintree::Transaction::Status::Voided
  end


  it "should be able to load transactions for given customer and credit_card" do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first
    transaction = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :customer => customer)

    customer.transactions.length.should == 1
    customer.transactions.each do |t|
     t.should == transaction
    end
    credit_card.transactions.count.should == 1
  end

  it "should be able to load all transactions for a given customer" do
    braintree_customer = Braintree::Customer.create!(customer_hash)
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card1 = customer.credit_cards.create!(credit_card_hash.merge(:token => nil))
    credit_card2 = customer.credit_cards.create!(credit_card_hash.merge(:token => nil))
    customer.credit_cards.size.should == 2

    transaction1 = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :customer => customer, :credit_card => credit_card1)
    transaction2 = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :customer => customer, :credit_card => credit_card2)
    customer.transactions.size.should == 2
  end

  it 'should be able to create a one time transaction' do
    transaction = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :billing => address_hash, :customer => customer_hash, :credit_card => credit_card_hash)
    transaction.should be_persisted
    transaction.id.should_not be_blank
    transaction.customer.should_not be_blank
    transaction.credit_card.should_not be_blank
  end

  it 'should be able to capture braintree api errors' do
    braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first
    transaction = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :customer => customer)

    transaction.void!
    transaction.submit_for_settlement.should be_false
    transaction.errors[:status].should_not be_blank
  end

  describe BraintreeRails::Transactions do
    describe '#default_options' do
      it 'can use default customer to build new record' do
        braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
        customer = BraintreeRails::Customer.new(braintree_customer)
        credit_card = customer.default_credit_card

        transaction = BraintreeRails::Transactions.new(customer).create!(:amount => (1..10).to_a.sample)
        transaction.customer.should == customer
        transaction.credit_card.should == credit_card
      end

      it 'can use default credit_card to build new record' do
        braintree_customer = Braintree::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
        customer = BraintreeRails::Customer.new(braintree_customer)
        credit_card = customer.default_credit_card

        transaction = BraintreeRails::Transactions.new(credit_card).create!(:amount => (1..10).to_a.sample)
        transaction.credit_card.should == credit_card
      end
    end

    describe '#reload' do
      it "should reload the collection" do
        customer = BraintreeRails::Customer.create!(customer_hash.merge(:credit_card => credit_card_hash))
        credit_card = customer.credit_cards.create!(credit_card_hash.merge(:token => 'card_1'))
        transactions = customer.transactions
        transactions.should be_empty

        transaction = BraintreeRails::Transaction.create!(:amount => (1..10).to_a.sample, :customer => customer, :credit_card => credit_card)
        transactions.reload.size.should == 1
      end
    end
  end
end
