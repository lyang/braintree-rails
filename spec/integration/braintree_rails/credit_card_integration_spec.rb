require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'Credit Card Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to fetch from Braintree for given token' do
    attributes = credit_card_hash()
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => attributes)

    credit_card = BraintreeRails::CreditCard.new(braintree_customer.credit_cards.first.token)

    attributes.except(:number, :cvv, :billing_address).each do |key, value|
      expect(credit_card.send(key)).to eq(value)
    end

    attributes[:billing_address].each do |key, value|
      expect(credit_card.billing_address.send(key)).to eq(value)
    end
  end

  it 'should be able to add credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    attributes = credit_card_hash()
    credit_card = customer.credit_cards.create!(attributes)

    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    attributes.except(:number, :cvv, :billing_address).each do |key, value|
      expect(braintree_credit_card.send(key)).to eq(value)
    end
    expect(credit_card.image_url).to eq(braintree_credit_card.image_url)

    braintree_address = braintree_credit_card.billing_address
    attributes[:billing_address].each do |key, value|
      expect(braintree_address.send(key)).to eq(value)
    end
  end

  it 'should be able to update existing credit card' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash)

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    expect(braintree_credit_card.cardholder_name).to eq('Foo Bar')
    expect(braintree_credit_card.billing_address.postal_code).to eq('56789')
  end

  it 'should be able to update just expiration year' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash.merge(:expiration_month => '07', :expiration_year => '2012'))

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :expiration_month => '07', :expiration_year => '2013', :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    expect(braintree_credit_card.cardholder_name).to eq('Foo Bar')
    expect(braintree_credit_card.billing_address.postal_code).to eq('56789')
    expect(braintree_credit_card.expiration_month).to eq('07')
    expect(braintree_credit_card.expiration_year).to eq('2013')
  end

  it 'should be able to update by expiration date' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    credit_card = customer.credit_cards.create!(credit_card_hash.merge(:expiration_month => '07', :expiration_year => '2012'))

    credit_card.update_attributes!(:cardholder_name => 'Foo Bar', :number => '4111111111111111', :options => {:verify_card => true}, :expiration_date => '08/2013', :billing_address => address_hash.merge(:postal_code => '56789'))
    braintree_credit_card = Braintree::CreditCard.find(credit_card.id)
    expect(braintree_credit_card.cardholder_name).to eq('Foo Bar')
    expect(braintree_credit_card.billing_address.postal_code).to eq('56789')
    expect(braintree_credit_card.expiration_month).to eq('08')
    expect(braintree_credit_card.expiration_year).to eq('2013')
    expect(braintree_credit_card.expiration_date).to eq('08/2013')
  end

  it 'should be able to destroy existing credit card' do
    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    credit_card = BraintreeRails::CreditCard.new(braintree_customer.credit_cards.first.token)

    credit_card.destroy!
    expect { Braintree::CreditCard.find(credit_card.token) }.to raise_error(Braintree::NotFoundError)
    expect(credit_card).to_not be_persisted
    expect(credit_card).to be_frozen
  end

  it 'should be able to capture braintree api errors' do
    customer = BraintreeRails::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree')
    expect {customer.credit_cards.create!(credit_card_hash.merge(:number => 'foo'))}.to raise_error(Braintree::ValidationsFailed)
  end
end
