require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'Customer Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should fetch customer from Braintree for given id' do
    braintree_customer = Braintree::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer = BraintreeRails::Customer.new(braintree_customer.id)
    customer.id.should == braintree_customer.id
    customer.first_name.should == 'Brain'
    customer.last_name.should == 'Tree'
    customer.should be_persisted
  end

  it 'should be able to create new customer' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree')
    braintree_customer = Braintree::Customer.find(customer.id)

    braintree_customer.first_name.should == 'Brain'
    braintree_customer.last_name.should == 'Tree'
  end

  it 'should be able to create new customer with a credit card' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_customer.credit_cards.count.should == 1
  end

  it 'should be able to update existing customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.update_attributes!(:first_name => 'Foo', :last_name => 'Bar')

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_customer.first_name.should == 'Foo'
    braintree_customer.last_name.should == 'Bar'
  end

  it 'should be able to update existing customer with new credit card' do
    customer = BraintreeRails::Customer.create(:first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    customer.update_attributes!(:first_name => 'Foo', :last_name => 'Bar', :credit_card => credit_card_hash.merge(:cardholder_name => "FooBar"))

    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_customer.credit_cards.first.cardholder_name.should == "FooBar"
  end

  it 'should be able to destroy existing customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.destroy
    expect { Braintree::Customer.find(customer.id) }.to raise_error(Braintree::NotFoundError)
    customer.should_not be_persisted
    customer.should be_frozen
  end

  it 'should not throw error when trying to destory an already destoryed customer' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.destroy
    expect { customer.destroy }.not_to raise_error()
    customer.should_not be_persisted
    customer.should be_frozen
  end

  it "should be able to reload the customer attributes" do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.first_name = 'new name'
    customer.reload.first_name.should == 'Brain'
  end

  it "should be able to reload associations" do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
    customer.credit_cards.should be_empty
    Braintree::CreditCard.create(credit_card_hash.merge(:customer_id => customer.id))
    customer.reload.credit_cards.size.should == 1
  end
end
