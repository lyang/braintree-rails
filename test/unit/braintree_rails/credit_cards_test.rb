require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::CreditCards do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::CreditCard' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_credit_cards = braintree_customer.credit_cards
      credit_cards = BraintreeRails::CreditCards.new(braintree_customer, braintree_credit_cards)

      credit_cards.size.must_equal braintree_credit_cards.size

      braintree_credit_cards.each do |braintree_credit_card|
        credit_card = credit_cards.find(braintree_credit_card.token)
        BraintreeRails::CreditCard.attributes.each do |attribute|
          credit_card.send(attribute).must_equal braintree_credit_card.send(attribute) if braintree_credit_card.respond_to?(attribute)
        end
      end
    end
  end

  describe '#build' do
    it 'should build new CreditCard object with customer_id and params' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_credit_cards = braintree_customer.credit_cards
      credit_cards = BraintreeRails::CreditCards.new(braintree_customer, braintree_credit_cards)
      credit_card = credit_cards.build({:first_name => 'foo', :last_name => 'bar'})

      credit_card.persisted?.must_equal false
      credit_card.customer_id.must_equal braintree_customer.id
      credit_card.first_name.must_equal 'foo'
      credit_card.last_name.must_equal 'bar'
    end
  end

  describe '#create' do
    it 'should add credit card to collection if creation succeeded' do
      stub_braintree_request(:post, '/payment_methods', :body => fixture('credit_card.xml'))

      braintree_customer = BraintreeRails::Customer.find('customer_id')
      credit_card = braintree_customer.credit_cards.create(credit_card_hash)
      credit_card.persisted?.must_equal true
      braintree_customer.credit_cards.must_include credit_card
    end

    it 'should not add credit card to collection if creation failed' do
      stub_braintree_request(:post, '/payment_methods', :body => fixture('credit_card_validation_error.xml'))

      braintree_customer = BraintreeRails::Customer.find('customer_id')
      credit_card = braintree_customer.credit_cards.create(credit_card_hash)
      credit_card.persisted?.must_equal false
      braintree_customer.credit_cards.wont_include credit_card
    end
  end
end
