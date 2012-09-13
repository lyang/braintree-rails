require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Address Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to add address' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
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
    customer.addresses.create!(address_hash)
    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    
    address_hash.each do |key, value|
      braintree_address.send(key).must_equal value
    end
  end

  it 'should be able to update existing address' do
    customer = BraintreeRails::Customer.create!(:first_name => 'Brain', :last_name => 'Tree')
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
    address = customer.addresses.create!(address_hash)
    address.update_attributes!(:first_name => 'Foo', :last_name => 'Bar')
    braintree_customer = Braintree::Customer.find(customer.id)
    braintree_address = braintree_customer.addresses.first
    
    braintree_address.first_name.must_equal 'Foo'
    braintree_address.last_name.must_equal 'Bar'
  end
end