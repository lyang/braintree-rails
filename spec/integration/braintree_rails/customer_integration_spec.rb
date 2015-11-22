require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'Customer Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should fetch customer from Braintree for given id' do
    braintree_customer = Braintree::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer = BraintreeRails::Customer.new(braintree_customer.id)
    expect(customer.id).to eq(braintree_customer.id)
    expect(customer.first_name).to eq('Brain')
    expect(customer.last_name).to eq('Tree')
    expect(customer).to be_persisted
  end

  it 'should be able to create new customer' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree')
    braintree_customer = Braintree::Customer.find(customer.id)

    expect(braintree_customer.first_name).to eq('Brain')
    expect(braintree_customer.last_name).to eq('Tree')
  end

  it 'should be able to create new customer with a credit card' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    braintree_customer = Braintree::Customer.find(customer.id)
    expect(braintree_customer.credit_cards.count).to eq(1)
  end

  it 'should be able to update existing customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.update_attributes!(:first_name => 'Foo', :last_name => 'Bar')

    braintree_customer = Braintree::Customer.find(customer.id)
    expect(braintree_customer.first_name).to eq('Foo')
    expect(braintree_customer.last_name).to eq('Bar')
  end

  it 'should be able to update existing customer with new credit card' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    customer.update_attributes!(:first_name => 'Foo', :last_name => 'Bar', :credit_card => credit_card_hash.merge(:cardholder_name => "FooBar"))

    braintree_customer = Braintree::Customer.find(customer.id)
    expect(braintree_customer.credit_cards.size).to eq(2)
    expect(braintree_customer.credit_cards.map(&:cardholder_name)).to include("FooBar")
  end

  it 'should be able to destroy existing customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.destroy
    expect { Braintree::Customer.find(customer.id) }.to raise_error(Braintree::NotFoundError)
    expect(customer).to_not be_persisted
    expect(customer).to be_frozen
  end

  it 'should not throw error when trying to destory an already destoryed customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.destroy
    expect { customer.destroy }.not_to raise_error()
    expect(customer).to_not be_persisted
    expect(customer).to be_frozen
  end

  it "should be able to reload the customer attributes" do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.first_name = 'new name'
    expect(customer.reload.first_name).to eq('Brain')
  end

  it "should be able to reload associations" do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    expect(customer.credit_cards).to be_empty
    Braintree::CreditCard.create(credit_card_hash.merge(:customer_id => customer.id))
    expect(customer.reload.credit_cards.size).to eq(1)
  end
end
