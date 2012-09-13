require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Credit Card Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to add credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    
    address_hash = {
      :first_name => 'Brain',
      :last_name => 'Tree',
      :company => 'Braintree',
      :street_address => '1134 Crane Avenue',
      :extended_address => 'Suite 200',
      :locality => 'Menlo Park',
      :region => 'California',
      :postal_code => '94025',
      :country_name => 'United States of America'
    }

    credit_card_hash = {
      :token => 'credit_card_id',
      :number => '4111111111111111',
      :cvv => '123',
      :customer_id => 'customer_id',
      :cardholder_name => 'Brain Tree',
      :expiration_month => '05',
      :expiration_year => '2037',
      :billing_address => address_hash,
    }

    credit_card = customer.credit_cards.create!(credit_card_hash)

    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    credit_card_hash.except(:number, :cvv, :billing_address).each do |key, value|
      braintree_credit_card.send(key).must_equal value
    end
    
    braintree_address = braintree_credit_card.billing_address
    address_hash.each do |key, value|
      braintree_address.send(key).must_equal value
    end
  end

  it 'should be able to update existing credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    
    address_hash = {
      :first_name => 'Brain',
      :last_name => 'Tree',
      :company => 'Braintree',
      :street_address => '1134 Crane Avenue',
      :extended_address => 'Suite 200',
      :locality => 'Menlo Park',
      :region => 'California',
      :postal_code => '94025',
      :country_name => 'United States of America'
    }

    credit_card_hash = {
      :token => 'credit_card_id',
      :number => '4111111111111111',
      :cvv => '123',
      :customer_id => 'customer_id',
      :cardholder_name => 'Brain Tree',
      :expiration_month => '05',
      :expiration_year => '2037',
      :billing_address => address_hash,
    }

    credit_card = customer.credit_cards.create!(credit_card_hash)

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar')
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    braintree_credit_card.cardholder_name.must_equal 'Foo Bar'
  end
end