require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::CreditCards do
  before do
    stub_braintree_request(:get, '/customers/customer_id', :body => fixture('customer.xml'))
  end

  describe '#initialize' do
    it 'should wrap an array of Braintree::CreditCard' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_credit_cards = braintree_customer.credit_cards
      credit_cards = Braintree::ActiveModel::CreditCards.new(braintree_customer, braintree_credit_cards)
      
      credit_cards.size.must_equal braintree_credit_cards.size

      braintree_credit_cards.each do |braintree_credit_card|
        credit_card = credit_cards.find(braintree_credit_card.token)
        Braintree::ActiveModel::CreditCard::Attributes.each do |attribute|
          credit_card.send(attribute).must_equal braintree_credit_card.send(attribute) if braintree_credit_card.respond_to?(attribute)
        end
      end
    end
  end

  describe '#build' do
    it 'should build new CreditCard object with customer_id and params' do
      braintree_customer = Braintree::Customer.find('customer_id')
      braintree_credit_cards = braintree_customer.credit_cards
      credit_cards = Braintree::ActiveModel::CreditCards.new(braintree_customer, braintree_credit_cards)
      credit_card = credit_cards.build({:first_name => 'foo', :last_name => 'bar'})

      credit_card.persisted?.must_equal false
      credit_card.customer_id.must_equal braintree_customer.id
      credit_card.first_name.must_equal 'foo'
      credit_card.last_name.must_equal 'bar'
    end
  end
end