require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Transaction do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
    stub_braintree_request(:get, '/payment_methods/credit_card/credit_card_id', :body => fixture('credit_card.xml'))
    stub_braintree_request(:get, '/transactions/transactionid', :body => fixture('transaction.xml'))
  end

  describe '#initialize' do
    it 'should find transaction from braintree when given a transaction id' do
      braintree_transaction = Braintree::Transaction.find('transactionid')
      transaction = BraintreeRails::Transaction.new('transactionid')

      expect(transaction).to be_persisted
      [:amount, :created_at, :updated_at].each do |attribute|
        expect(transaction.send(attribute)).to eq(braintree_transaction.send(attribute))
      end
    end

    it 'should wrap a Braintree::Transaction' do
      braintree_transaction = Braintree::Transaction.find('transactionid')
      transaction = BraintreeRails::Transaction.new(braintree_transaction)

      expect(transaction).to be_persisted
      [:amount, :created_at, :updated_at].each do |attribute|
        expect(transaction.send(attribute)).to eq(braintree_transaction.send(attribute))
      end
    end

    it 'should extract values from hash' do
      transaction = BraintreeRails::Transaction.new(:id => 'new_id')

      expect(transaction).to_not be_persisted
      expect(transaction.id).to eq('new_id')
    end

    it 'should try to extract value from other types' do
      transaction = BraintreeRails::Transaction.new(OpenStruct.new(:id => 'foobar', :amount => '10.00', :persisted? => true))

      expect(transaction).to be_persisted
      expect(transaction.id).to eq('foobar')
      expect(transaction.amount).to eq('10.00')

      transaction = BraintreeRails::Transaction.new(Object.new)
      expect(transaction).to_not be_persisted
    end
  end

  [:customer, :credit_card, :billing, :shipping].each do |association|
    describe association do
      it "should load #{association} for persisted transaction" do
        transaction = BraintreeRails::Transaction.new('transactionid')
        expect(transaction.send(association)).to be_persisted
      end

      it "should keep #{association} nil if assigned nil value" do
        transaction = BraintreeRails::Transaction.new(association => nil)
        expect(transaction.send(association)).to be_nil
      end
    end
  end

  [:add_ons, :discounts].each do |association|
    describe "##{association}" do
      it 'behaves like enumerable' do
        braintree_transaction = Braintree::Transaction.find('transactionid')
        transaction = BraintreeRails::Transaction.new(braintree_transaction)

        expect(transaction.send(association)).to respond_to(:each)
        expect(transaction.send(association).size).to eq(braintree_transaction.send(association).size)
      end
    end
  end

  describe 'validations' do
    it 'should validate amount' do
      [nil, 'abc', -1].each do |invalid_value|
        transaction = BraintreeRails::Transaction.new(:amount => invalid_value)
        expect(transaction).to_not be_valid
        expect(transaction.errors[:amount]).to_not be_blank
      end

      [10, 10.0, "10", "10.00"].each do |valid_value|
        transaction = BraintreeRails::Transaction.new(:amount => valid_value)
        transaction.valid?
        expect(transaction.errors[:amount]).to be_blank
      end
    end

    it 'should validate type' do
      ['refund', 'abc'].each do |invalid_value|
        transaction = BraintreeRails::Transaction.new(:type => invalid_value)
        expect(transaction).to_not be_valid
        expect(transaction.errors[:type]).to_not be_blank
      end

      ['sale', 'credit'].each do |valid_value|
        transaction = BraintreeRails::Transaction.new(:type => valid_value)
        transaction.valid?
        expect(transaction.errors[:type]).to be_blank
      end
    end

    describe 'credit card' do
      it 'is valid if new credit card with valid billing address' do
        transaction = BraintreeRails::Transaction.new(:amount => 10, :billing => address_hash, :credit_card => credit_card_hash)
        expect(transaction).to be_valid

        transaction = BraintreeRails::Transaction.new(:amount => 10, :credit_card => credit_card_hash)
        expect(transaction).to_not be_valid
      end

      it 'is valid if credit card is persisted' do
        transaction = BraintreeRails::Transaction.new(:amount => 10, :credit_card => BraintreeRails::CreditCard.find('credit_card_id'))
        expect(transaction).to be_valid
      end

      it 'is valid if customer has default credit card' do
        transaction = BraintreeRails::Transaction.new(:amount => 10, :customer => BraintreeRails::Customer.find('customer_id'))
        expect(transaction).to be_valid

        transaction = BraintreeRails::Transaction.new(:amount => 10, :customer => customer_hash)
        expect(transaction).to_not be_valid
      end

      it 'should not validate credit card if already persisted' do
        transaction = BraintreeRails::Transaction.new(OpenStruct.new(:amount => 10, :persisted? => true))
        expect(transaction).to be_valid
      end
    end
  end

  describe '#attribute_for_create' do
    it 'should default type to sale' do
      expect(BraintreeRails::Transaction.new.send(:attributes_for, :create)[:type]).to eq('sale')
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

      expect(transaction.save).to eq(true)
      expect(transaction.status).to eq(Braintree::Transaction::Status::Authorized)
    end

    it 'should create a sale transaction from new credit card' do
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :billing => address_hash, :credit_card => credit_card_hash)
      transaction.valid?
      expect(transaction.save).to eq(true)
      expect(transaction.status).to eq(Braintree::Transaction::Status::Authorized)
    end

    it 'should clear encrypted attributes even when save failed' do
      transaction = BraintreeRails::Transaction.new(:amount => 'foo', :credit_card => credit_card_hash)
      expect(transaction.save).to eq(false)
      expect(transaction.credit_card.number).to be_blank
    end

    it 'should clear encrypted attributes after save' do
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :billing => address_hash, :credit_card => credit_card_hash)
      transaction.valid?
      expect(transaction.save).to eq(true)
      expect(transaction.credit_card.number).to be_blank
    end

    it 'should clear encrypted attributes' do
      transaction = BraintreeRails::Transaction.new(:credit_card => credit_card_hash)
      transaction.clear_encryped_attributes
      expect(transaction.credit_card.number).to be_blank
    end

    it 'should use default credit card of customer if credit_card is not specified' do
      customer = BraintreeRails::Customer.find('customer_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer)
      expect(transaction.save).to eq(true)
      expect(transaction.status).to eq(Braintree::Transaction::Status::Authorized)
    end

    it "should be able to submit_for_settlement a authorized transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      stub_braintree_request(:put, "/transactions/#{transaction.id}/submit_for_settlement", :body => fixture('transaction.xml'))
      expect(transaction.submit_for_settlement).to eq(true)
      transaction.status = Braintree::Transaction::Status::Settled
      expect(transaction.submit_for_settlement).to eq(false)
    end

    it "should be able to refund a settled transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      transaction.status = Braintree::Transaction::Status::Settled
      stub_braintree_request(:post, "/transactions/#{transaction.id}/refund", :body => fixture('transaction.xml'))
      expect(transaction.refund).to eq(true)
      transaction.status = Braintree::Transaction::Status::Authorized
      expect(transaction.refund).to eq(false)
    end

    it "should be able to void a authorized transaction" do
      transaction = BraintreeRails::Transaction.find('transactionid')
      stub_braintree_request(:put, "/transactions/#{transaction.id}/void", :body => fixture('transaction.xml'))
      expect(transaction.void).to eq(true)
      transaction.status = Braintree::Transaction::Status::Settled
      expect(transaction.void).to eq(false)
    end

    it 'should show errors when trying to submit already voided transaction' do
      transaction = BraintreeRails::Transaction.find('transactionid')
      transaction.status = Braintree::Transaction::Status::Voided
      expect(transaction.submit_for_settlement).to eq(false)
      expect(transaction.errors[:status]).to_not be_blank

      expect {transaction.submit_for_settlement!}.to raise_error(BraintreeRails::RecordInvalid)
    end

    it 'should propergate api errors to credit card if any' do
      customer = BraintreeRails::Customer.find('customer_id')
      credit_card = BraintreeRails::CreditCard.find('credit_card_id')
      transaction = BraintreeRails::Transaction.new(:amount => '10.00', :customer => customer, :credit_card => credit_card)
      stub_braintree_request(:post, '/transactions', :status => 422, :body => fixture('transaction_error.xml'))
      transaction.save
      expect(transaction.errors[:base]).to eq(["Credit card type is not accepted by this merchant account."])
      expect(transaction.credit_card.errors.full_messages).to eq(["Number Credit card number is invalid."])
      expect(transaction.credit_card.errors[:number].first.code).to eq("81715")
      expect(transaction.credit_card.errors[:number].first.message).to eq("Credit card number is invalid.")
      expect(transaction.credit_card.errors[:number].first.to_s).to eq("Credit card number is invalid.")
    end

    it 'does not support update or destroy' do
      expect {BraintreeRails::Transaction.find('transactionid').update_attributes(:amount => 1)}.to raise_error(BraintreeRails::NotSupportedApiException)
      expect {BraintreeRails::Transaction.find('transactionid').destroy!}.to raise_error(BraintreeRails::NotSupportedApiException)
    end
  end
end