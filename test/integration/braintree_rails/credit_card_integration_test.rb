require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Credit Card Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to fetch from Braintree for given token' do
    attributes = credit_card_hash()
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => attributes)

    credit_card = BraintreeRails::CreditCard.new(braintree_customer.credit_cards.first.token)

    attributes.except(:number, :cvv, :billing_address).each do |key, value|
      credit_card.send(key).must_equal value
    end

    attributes[:billing_address].each do |key, value|
      credit_card.billing_address.send(key).must_equal value
    end
  end

  it 'should be able to add credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    attributes = credit_card_hash()
    credit_card = customer.credit_cards.create!(attributes)

    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    attributes.except(:number, :cvv, :billing_address).each do |key, value|
      braintree_credit_card.send(key).must_equal value
    end

    braintree_address = braintree_credit_card.billing_address
    attributes[:billing_address].each do |key, value|
      braintree_address.send(key).must_equal value
    end
  end

  it 'should be able to update existing credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash)

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar')
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    braintree_credit_card.cardholder_name.must_equal 'Foo Bar'
  end

  it 'should be able to destroy existing credit card' do
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    credit_card = BraintreeRails::CreditCard.new(braintree_customer.credit_cards.first.token)

    credit_card.destroy!
    lambda{ Braintree::CreditCard.find(credit_card.token) }.must_raise Braintree::NotFoundError
    credit_card.persisted?.must_equal false
    credit_card.frozen?.must_equal true
  end
end
