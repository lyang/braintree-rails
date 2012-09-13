braintree-rails
===============
braintree-rails provides ActiveModel compatible(mostly) wrappers around the raw ruby client library.

For example:

    BraintreeRails::Customer.new({}).persisted? # => false
    
    BraintreeRails::Customer.new(customer_id).persisted? # => true
    
    BraintreeRails::Customer.new(Braintree::Customer.find(customer_id)).persisted? # => true
    
    customer.credit_cards # => [credit_card]
    
    customer.addresses # => [address]

    address = customer.addresses.create!(:first_name => 'Foo')

    card = customer.credit_cards.build(:first_name => 'Foo')
    
    card.valid? # => false, local validations, rules based on Braintree's documents listed below.
    
    card.errors # => ActiveModel::Errors
    
    card.save # => false
    
    card.update_attributes(:last_name => 'Bar')
    
    customer.destroy!

You get how it works, right?

NOTICE
---------------

The local validations are solely based on Braintree's document. For length and numericallity checks it works fine, but it can't verify credit card numbers etc without resulting to Braintree's API.

So, be prepared to get validation errors from Braintree even if the local validations have passed.

Currently cvv, street address, postal code are required for creation/updating credit cards as per Braintree's strong recommendations.

Braintree
---------------
Braintree is a payments company that provides elegant tools for developers and white-glove support.

Braintree ruby client library
---------------
Source code: https://github.com/braintree/braintree_ruby

Documents:   http://www.braintreepayments.com/docs/ruby