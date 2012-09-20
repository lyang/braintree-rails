braintree-rails [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/lyang/braintree-rails)
===============
braintree-rails provides ActiveModel compatible(mostly) wrappers around the raw ruby client library.

You can check out the demo app at [braintree-rails-example](https://github.com/lyang/braintree-rails-example).

The demo app shows how you can treat the resources stored in Braintree's vault as if it's in your database.

Initialization
---------------
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ''
    Braintree::Configuration.public_key = ''
    Braintree::Configuration.private_key = ''
    
CRUD
---------------
    customer = BraintreeRails::Customer.new({:first_name => 'Foo'}) # new record

    customer.save! # => persisted

    customer = BraintreeRails::Customer.new(customer.id) # fetched from Braintree for given id

    customer = BraintreeRails::Customer.new(Braintree::Customer.find(customer.id)) # wrapping Braintree model objects

    customer = BraintreeRails::Customer.create!(:first_name => 'Foo')

    customer = BraintreeRails::Customer.find(customer.id)
    
    customer.company = 'Foo Bar'

    customer.save!

    customer.update_attributes(:website => 'www.example.com')

    customer.update_attributes!(:email => 'foobar@example.com')
    
    customer.destroy
    
Associations
---------------
    
    customer = BraintreeRails::Customer.create!(:first_name => 'Foo')

    customer.credit_cards # => []

    credit_card = customer.credit_cards.build(
      :cardholder_name => 'Foo',
      :number => '4111111111111111',
      :cvv => '123',
      :expiration_month => '12',
      :expiration_year => '2020',
      :billing_address => {:street_address => 'Foo St', :postal_code => '12345'}
    )

    credit_card.save

    transaction = credit_card.transactions.create!(:amount => '10.00') # => authorized

    transaction.submit_for_settlement # => submitted_for_settlement

    transaction.void! # => voided
    
    transaction.void! # => raises Braintree::ValidationsFailed

Validations
---------------
    credit_card = customer.credit_cards.build({})
    
    credit_card.save! # => raises RecordInvalid

    credit_card.errors # => ActiveModel::Errors

    credit_card.valid? # => false
    
    credit_card.assign_attributes(
      :cardholder_name => 'Foo',
      :number => '4111111111111111',
      :cvv => '123',
      :expiration_month => '12',
      :expiration_year => '2020',
      :billing_address => {:street_address => 'Foo St', :postal_code => '12345'}
    )

    credit_card.save! # => true

Forms
---------------
    = simple_form_for @credit_card, :url => url, :html => { :class => 'form-horizontal' } do |f|
      = f.input :number if @credit_card.new_record?
      = f.input :cardholder_name
      = f.input :cvv, :maxlength => 4, :label => 'CVV'
      = f.input :expiration_month, options_for_month_select
      = f.input :expiration_year, options_for_year_select
      = f.simple_fields_for :billing_address, @credit_card.billing_address do |ba|
        = ba.input :first_name
        = ba.input :last_name
        = ba.input :company
        = ba.input :street_address
        = ba.input :extended_address
        = ba.input :locality, :label => 'City'
        = ba.input :country_code_alpha2, options_for_country_select
        = ba.input :region, options_for_region_select
        = ba.input :postal_code
      .form-actions
        = f.button :submit, :class => 'btn-primary'
        = link_to 'Cancel', user_customer_credit_cards_path(@user), :class => 'btn'

Controllers
--------------
    class TransactionsController < ApplicationController
      ...
      def index
        @transactions = (@credit_card || @customer).transactions    
      end
  
      def new
        @transaction = @customer.transactions.build(:amount => "10.00")
      end
  
      def create
        @transaction = @customer.transactions.build(params[:transaction])
        if @transaction.save
          flash[:notice] = "Transaction has been successfully created."
          redirect_to user_customer_transaction_path(@user, @transaction.id)
        else
          flash.now[:alert] = @transaction.errors[:base].join("\n")
          render :new
        end
      end
      ...
    end

Check out [braintree-rails-example](https://github.com/lyang/braintree-rails-example) for complete examples.

Todos
---------------
1. Adding support for subscriptions.
2. Adding a Arel like query interface?

NOTICE
---------------
This IS NOT created or maintained by Braintree.

The local validations are solely based on Braintree's document. For length and numericallity checks it works fine, but it can't verify credit card numbers etc without resulting to Braintree's API.

So, be prepared to get validation errors from Braintree even if the local validations have passed.

Currently cvv, street address, postal code are required for creating/updating credit cards as per Braintree's strong recommendations.


Braintree
---------------
Braintree is a payments company that provides elegant tools for developers and white-glove support.

Braintree ruby client library
---------------
Source code: https://github.com/braintree/braintree_ruby

Documents:   http://www.braintreepayments.com/docs/ruby