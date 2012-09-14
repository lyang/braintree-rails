braintree-rails
===============
braintree-rails provides ActiveModel compatible(mostly) wrappers around the raw ruby client library.

For example:

    BraintreeRails::Customer.new({}) # new record
    
    BraintreeRails::Customer.new(customer_id) # fetched from Braintree for given id
    
    BraintreeRails::Customer.new(Braintree::Customer.find(customer_id)) # wrapping Braintree model objects
    
    BraintreeRails::Customer.find(id) # delegated to Braintree::Customer.find
    
    BraintreeRails::Customer.delete(id) # same as above
    
    BraintreeRails::Customer.create!(:first_name => 'Foo')
    
    customer.credit_cards # => [credit_card], Array like associations 
    
    customer.addresses # => [address]

    address = customer.addresses.create!(:first_name => 'Foo')

    card = customer.credit_cards.build(:cardholder_name => 'Foo', :billing_address => {:stree_adress => 'Bar'})
    
    card.valid? # => false, local validations, rules based on Braintree's documents listed below.
    
    card.errors # => ActiveModel::Errors
    
    card.save # => false
    
    card.update_attributes(:last_name => 'Bar')
    
    customer.destroy!

You get how it works, right?

NOTICE
---------------
This IS NOT from or maintained by Braintree.


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