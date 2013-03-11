# braintree-rails [![Build Status](https://secure.travis-ci.org/lyang/braintree-rails.png)](http://travis-ci.org/lyang/braintree-rails) [![Code Climate](https://codeclimate.com/github/lyang/braintree-rails.png)](https://codeclimate.com/github/lyang/braintree-rails) #

## Welcome to braintree-rails
braintree-rails is a framework that wraps the official [braintree_ruby](https://github.com/braintree/braintree_ruby) client library and provides ActiveModel compatible models than can be easily fit into an rails app.

## Why braintree-rails
While the official [braintree_ruby](https://github.com/braintree/braintree_ruby) gem is already quite easy to use, it is designed as a general ruby gem with very few dependencies, which is great.

However this generality does translate to a bit of boiler plate code to make it feel like "the rails way" in a rails app. For example, rendering a payment form with api error messages, or custom validations before sending outbound api calls. So, here goes the boiler plate code for your convenience.

In addition to the "railsy" interface, there are also some feature enhancements. For example, you can add custom validations or callbacks to each model.

Last, all braintree-rails uses behind the scenes are only the public APIs the official [braintree_ruby](https://github.com/braintree/braintree_ruby) provides. It does not touch any of the actual http request.

## Features


1.  #### CRUD ####

		customer = BraintreeRails::Customer.new(:first_name => 'Foo') # new record
		
		customer.save! # => persisted
		
		customer = BraintreeRails::Customer.new(customer.id) # fetched from Braintree for given id
		
		customer = BraintreeRails::Customer.new(Braintree::Customer.find(customer.id)) # wrapping Braintree model objects
		
		customer = BraintreeRails::Customer.create!(:first_name => 'Foo') # => persisted
		
		customer = BraintreeRails::Customer.find(customer.id) # find by id
		
		customer.company = 'Foo Bar'
		
		customer.save! # => updates or raises RecordInvalid
		
		customer.update_attributes(:website => 'www.example.com') # updates or with customer.errors populated
		
		customer.update_attributes!(:email => 'foobar@example.com') # updates or raises RecordInvalid
		
		customer.destroy # delete the customer from the Vault

2.  #### Associations ####

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
		
		credit_card.save # => add the credit card to the customer
		
		transaction = credit_card.transactions.create!(:amount => '10.00') # => create transaction from the credit card

3.  #### Validations ####
		module BraintreeRails
		  class TransactionValidator < Validator
		    Validations = [
		      [:amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}, :if => :new_record?],
		      [:type, :presence => true, :inclusion => {:in => %w(sale credit)}, :if => :new_record?],
		      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Authorized]}, :on => :submit_for_settlement],
		      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Settled, Braintree::Transaction::Status::Settling]}, :on => :refund],
		      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Authorized, Braintree::Transaction::Status::SubmittedForSettlement]}, :on => :void]
		    ]
		  ...
		  end
		end

4.  #### Used in Forms ####

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

5.  #### Used in Controllers ####

		class TransactionsController < ApplicationController
		  ...
		  def new
		    @transaction = @transactions.build
		  end
		
		  def create
		    @transaction = @transactions.build(params[:transaction])
		    if @transaction.save
		      flash[:notice] = "Transaction has been successfully created."
		      redirect_to transaction_path(@transaction)
		    else
		      flash.now[:alert] = @transaction.errors.full_messages.join("\n")
		      render :new
		    end
		  end
		  ...
		end


## Documents ##
While the complete feature docs are work in progress, you can check out a demo rails app at [braintree-rails-example](https://github.com/lyang/braintree-rails-example) as a quick start guide.


## Todos ##
Write better documents.

## Braintree ruby client library ##
Source code: [braintree_ruby](https://github.com/braintree/braintree_ruby)

Documents:   [Ruby Client Library](https://www.braintreepayments.com/docs/ruby)
