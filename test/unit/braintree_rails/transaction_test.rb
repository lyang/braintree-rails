require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Transaction do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    stub_braintree_request(:get, '/payment_methods/credit_card_id', :body => fixture('credit_card.xml'))
    stub_braintree_request(:get, '/transactions/transaction_id', :body => fixture('transaction.xml'))
  end

  describe '#initialize' do
    it 'should find transaction from braintree when given a transaction id' do
      braintree_transaction = Braintree::Transaction.find('transaction_id')
      transaction = BraintreeRails::Transaction.new('transaction_id')

      transaction.persisted?.must_equal true
      [:amount, :created_at, :updated_at].each do |attribute|
        transaction.send(attribute).must_equal braintree_transaction.send(attribute)
      end
    end

    it 'should wrap a Braintree::Transaction' do
      braintree_transaction = Braintree::Transaction.find('transaction_id')
      transaction = BraintreeRails::Transaction.new(braintree_transaction)

      transaction.persisted?.must_equal true
      [:amount, :created_at, :updated_at].each do |attribute|
        transaction.send(attribute).must_equal braintree_transaction.send(attribute)
      end
    end

    it 'should extract values from hash' do
      transaction = BraintreeRails::Transaction.new(:id => 'new_id')

      transaction.persisted?.must_equal false
      transaction.id.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      transaction = BraintreeRails::Transaction.new(OpenStruct.new(:id => 'foobar', :amount => '10.00', :persisted? => true))

      transaction.persisted?.must_equal true
      transaction.id.must_equal 'foobar'
      transaction.amount.must_equal '10.00'

      transaction = BraintreeRails::Transaction.new(Object.new)
      transaction.persisted?.must_equal false
    end
  end

  [:customer, :credit_card].each do |association|
    describe association do
      it "should load #{association} for persisted transaction" do
        transaction = BraintreeRails::Transaction.new('transaction_id')
        transaction.send(association).persisted?.must_equal true
      end
    end    
  end

  describe 'validations' do
    it 'should validate amount' do
      [nil, 'abc', -1].each do |invalid_value|
        transaction = BraintreeRails::Transaction.new(:amount => invalid_value)
        transaction.valid?.must_equal false
        transaction.errors[:amount].wont_be :blank?
      end        
    end
  end

  describe 'persistence' do
    before do
      stub_braintree_request(:post, '/transactions', :body => fixture('transaction.xml'))
    end

    it 'should create a sale transaction' do
      customer = BraintreeRails::Customer.find('customer_id')
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer, :credit_card => credit_card)

      transaction.save.must_equal true
      transaction.status.must_equal Braintree::Transaction::Status::Authorized
    end

    it 'should use default credit card of customer if credit_card is not specified' do
      customer = BraintreeRails::Customer.find('customer_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer)
      transaction.save.must_equal true
      transaction.status.must_equal Braintree::Transaction::Status::Authorized
    end

    [:submit_for_settlement, :refund, :void].each do |operation|
      it "should be able to #{operation} a transaction" do
        customer = BraintreeRails::Customer.find('customer_id')
        credit_card = BraintreeRails::CreditCard.find('credit_card_id')
        transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer, :credit_card => credit_card)
        transaction.save

        lambda{transaction.send(operation)}.must_be_silent
      end
    end
  end
end