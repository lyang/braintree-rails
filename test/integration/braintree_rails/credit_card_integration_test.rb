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

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    braintree_credit_card.cardholder_name.must_equal 'Foo Bar'
    braintree_credit_card.billing_address.postal_code.must_equal '56789'
  end

  it 'should be able to update just expiration year' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash.merge(:expiration_month => '07', :expiration_year => '2012'))

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :expiration_month => '07', :expiration_year => '2013', :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    braintree_credit_card.cardholder_name.must_equal 'Foo Bar'
    braintree_credit_card.billing_address.postal_code.must_equal '56789'
    braintree_credit_card.expiration_month.must_equal '07'
    braintree_credit_card.expiration_year.must_equal '2013'
  end

  it 'should be able to update by expiration date' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash.merge(:expiration_month => '07', :expiration_year => '2012'))

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :expiration_date => '08/2013', :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    braintree_credit_card.cardholder_name.must_equal 'Foo Bar'
    braintree_credit_card.billing_address.postal_code.must_equal '56789'
    braintree_credit_card.expiration_month.must_equal '08'
    braintree_credit_card.expiration_year.must_equal '2013'
    braintree_credit_card.expiration_date.must_equal '08/2013'
  end

  it 'should be able to destroy existing credit card' do
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    credit_card = BraintreeRails::CreditCard.new(braintree_customer.credit_cards.first.token)

    credit_card.destroy!
    lambda{ Braintree::CreditCard.find(credit_card.token) }.must_raise Braintree::NotFoundError
    credit_card.persisted?.must_equal false
    credit_card.frozen?.must_equal true
  end

  it 'should be able to capture braintree api errors' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    lambda{customer.credit_cards.create!(credit_card_hash.merge(:number => 'foo'))}.must_raise Braintree::ValidationsFailed
  end
end
