require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Transaction do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    stub_braintree_request(:get, '/payment_methods/credit_card_id', :body => fixture('credit_card.xml'))
    stub_braintree_request(:get, '/transactions/transactionid', :body => fixture('transaction.xml'))
  end

  describe '#initialize' do
    it 'should find transaction from braintree when given a transaction id' do
      braintree_transaction = Braintree::Transaction.find('transactionid')
      transaction = BraintreeRails::Transaction.new('transactionid')

      transaction.persisted?.must_equal true
      [:amount, :created_at, :updated_at].each do |attribute|
        transaction.send(attribute).must_equal braintree_transaction.send(attribute)
      end
    end

    it 'should wrap a Braintree::Transaction' do
      braintree_transaction = Braintree::Transaction.find('transactionid')
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

  [:customer, :credit_card, :billing, :shipping].each do |association|
    describe association do
      it "should load #{association} for persisted transaction" do
        transaction = BraintreeRails::Transaction.new('transactionid')
        transaction.send(association).persisted?.must_equal true
      end

      it "should keep #{association} nil if assigned nil value" do
        transaction = BraintreeRails::Transaction.new(association => nil)
        transaction.send(association).class.must_equal NilClass
      end
    end
  end

  [:add_ons, :discounts].each do |association|
    describe "##{association}" do
      it 'behaves like enumerable' do
        braintree_transaction = Braintree::Transaction.find('transactionid')
        transaction = BraintreeRails::Transaction.new(braintree_transaction)

        transaction.send(association).must_be_kind_of(Enumerable)
        transaction.send(association).size.must_equal braintree_transaction.send(association).size
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

  describe '#attribute_for_create' do
    it 'should default type to sale' do
      BraintreeRails::Transaction.new.send(:attributes_for, :create).must_equal :type => 'sale'
    end
  end

  describe 'persistence' do
    before do
      stub_braintree_request(:post, '/transactions', :body => fixture('transaction.xml'))
    end

    it 'should create a sale transaction from existing credit card' do
      customer = BraintreeRails::Customer.find('customer_id')
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer, :credit_card => credit_card)

      transaction.save.must_equal true
      transaction.status.must_equal Braintree::Transaction::Status::Authorized
    end

    it 'should create a sale transaction from new credit card' do
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :credit_card => credit_card_hash)
      transaction.valid?
      transaction.save.must_equal true
      transaction.status.must_equal Braintree::Transaction::Status::Authorized
    end

    it 'should clear encrypted attributes even when save failed' do
      transaction = BraintreeRails::Transaction.new(:amount => 'foo', :credit_card => credit_card_hash)
      transaction.save.must_equal false
      transaction.credit_card.number.must_be :blank?
    end

    it 'should clear encrypted attributes after save' do
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :credit_card => credit_card_hash)
      transaction.save.must_equal true
      transaction.credit_card.number.must_be :blank?
    end

    it 'should clear encrypted attributes' do
      transaction = BraintreeRails::Transaction.new(:credit_card => credit_card_hash)
      transaction.clear_encryped_attributes
      transaction.credit_card.number.must_be :blank?
    end

    it 'should use default credit card of customer if credit_card is not specified' do
      customer = BraintreeRails::Customer.find('customer_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer)
      transaction.save.must_equal true
      transaction.status.must_equal Braintree::Transaction::Status::Authorized
    end

    it "should be able to submit_for_settlement a authorized transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      stub_braintree_request(:put, "/transactions/#{transaction.id}/submit_for_settlement", :body => fixture('transaction.xml'))
      transaction.submit_for_settlement.must_equal true
      transaction.status = Braintree::Transaction::Status::Settled
      transaction.submit_for_settlement.must_equal false
    end

    it "should be able to refund a settled transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      transaction.status = Braintree::Transaction::Status::Settled
      stub_braintree_request(:post, "/transactions/#{transaction.id}/refund", :body => fixture('transaction.xml'))
      transaction.refund.must_equal true
      transaction.status = Braintree::Transaction::Status::Authorized
      transaction.refund.must_equal false
    end

    it "should be able to void a authorized transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      stub_braintree_request(:put, "/transactions/#{transaction.id}/void", :body => fixture('transaction.xml'))
      transaction.void.must_equal true
      transaction.status = Braintree::Transaction::Status::Settled
      transaction.void.must_equal false
    end

    it 'should show errors when trying to submit already voided transaction' do
      transaction = BraintreeRails::Transaction.find('transactionid')
      transaction.status = Braintree::Transaction::Status::Voided
      transaction.submit_for_settlement.must_equal false
      transaction.errors[:status].wont_be :blank?

      lambda{transaction.submit_for_settlement!}.must_raise BraintreeRails::RecordInvalid
    end

    it 'should propergate errors to credit card if any' do
      customer = BraintreeRails::Customer.find('customer_id')
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer, :credit_card => credit_card)
      stub_braintree_request(:post, '/transactions', :status => 422, :body => fixture('transaction_error.xml'))
      transaction.save
      transaction.credit_card.errors.wont_be :blank?
    end

    it 'does not support update or destroy' do
      lambda{BraintreeRails::Transaction.find('transactionid').update_attributes(:amount => 1)}.must_raise BraintreeRails::NotSupportedApiException
      lambda{BraintreeRails::Transaction.find('transactionid').destroy!}.must_raise BraintreeRails::NotSupportedApiException
    end
  end
end
