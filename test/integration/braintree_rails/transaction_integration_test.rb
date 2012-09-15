require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'Transaction Integration' do
  before do
    Braintree::Customer.all.each { |c| Braintree::Customer.delete c.id }
  end

  it 'should be able to create, submit, void transactions for a customer' do
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
      :cardholder_name => 'Brain Tree',
      :expiration_month => '05',
      :expiration_year => '2037',
      :billing_address => address_hash,
    }

    braintree_customer = Braintree::Customer.create!(:id => 'customer_id', :first_name => 'Brain', :last_name => 'Tree', :credit_card => credit_card_hash)
    customer = BraintreeRails::Customer.new(braintree_customer)
    credit_card = customer.credit_cards.first

    [{:amount => 10.00, :customer => customer}, {:amount => 20.00, :customer => customer, :credit_card => credit_card}].each do |params|
      transaction = BraintreeRails::Transaction.create!(params)
      transaction.persisted?.must_equal true
      transaction.amount.must_equal params[:amount]
      transaction.status.must_equal Braintree::Transaction::Status::Authorized

      transaction.submit_for_settlement!
      transaction.status.must_equal Braintree::Transaction::Status::SubmittedForSettlement

      transaction.void!
      transaction.status.must_equal Braintree::Transaction::Status::Voided
    end
  end
end