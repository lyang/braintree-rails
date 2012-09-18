braintree-rails
===============
braintree-rails provides ActiveModel compatible(mostly) wrappers around the raw ruby client library.

You can check out the demo app at [braintree-rails-example](https://github.com/lyang/braintree-rails-example).

The demo app shows how you can treat the resources stored in Braintree's vault as if it's in your database.

Initialization
---------------

    BraintreeRails::Customer.new({}) # new record
    
    BraintreeRails::Customer.new(customer_id) # fetched from Braintree for given id
    
    BraintreeRails::Customer.new(Braintree::Customer.find(customer_id)) # wrapping Braintree model objects
    
CRUD
---------------

    BraintreeRails::Customer.find(id) # delegated to Braintree::Customer.find
    
    BraintreeRails::Customer.delete(id) # same as above
    
    BraintreeRails::Customer.create!(:first_name => 'Foo')

    customer.update_attributes(:last_name => 'Bar')
    
    customer.destroy!
    
Associations
---------------

    customer.credit_cards # => [credit_card], Array like associations 
    
    customer.addresses # => [address]

    address = customer.addresses.create!(:first_name => 'Foo') # => persisted

    card = customer.credit_cards.build(:cardholder_name => 'Foo', :billing_address => {:street_adress => 'Bar'}) # => new_record

Validations
---------------

    card.save # => false

    card.valid? # => false, local validations, rules based on Braintree's documents listed below.
    
    card.errors # => ActiveModel::Errors

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