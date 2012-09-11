require File.expand_path(File.join(File.dirname(__FILE__), '../../unit_test_helper'))

describe Braintree::ActiveModel::CreditCard do
  before do
    stub_braintree_request(:get, '/payment_methods/credit_card_id', :body => fixture('credit_card.xml'))
  end

  describe '#initialize' do
    it 'should find credit_card from braintree when given a credit_card id' do
      credit_card = Braintree::ActiveModel::CreditCard.new('credit_card_id')
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')

      credit_card.persisted?.must_equal true
      Braintree::ActiveModel::CreditCard::Attributes.each do |attribute|
        credit_card.send(attribute).must_equal(braintree_credit_card.send(attribute)) if braintree_credit_card.respond_to?(attribute)
      end
    end

    it 'should wrap a Braintree::CreditCard' do
      braintree_credit_card = Braintree::CreditCard.find('credit_card_id')
      credit_card = Braintree::ActiveModel::CreditCard.new(braintree_credit_card)

      credit_card.persisted?.must_equal true
      Braintree::ActiveModel::CreditCard::Attributes.each do |attribute|
        credit_card.send(attribute).must_equal(braintree_credit_card.send(attribute)) if braintree_credit_card.respond_to?(attribute)
      end
    end

    it 'should extract values from hash' do
      credit_card = Braintree::ActiveModel::CreditCard.new(:token => 'new_id')

      credit_card.persisted?.must_equal false
      credit_card.token.must_equal 'new_id'
    end

    it 'should try to extract value from other types' do
      credit_card = Braintree::ActiveModel::CreditCard.new(OpenStruct.new(:token => 'foobar', :cardholder_name => 'Foo Bar', :persisted? => true))

      credit_card.persisted?.must_equal true
      credit_card.token.must_equal 'foobar'
      credit_card.cardholder_name.must_equal 'Foo Bar'

      credit_card = Braintree::ActiveModel::CreditCard.new(OpenStruct.new({}))
      credit_card.persisted?.must_equal false
    end
  end
end