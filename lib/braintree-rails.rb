require File.expand_path(File.join(File.dirname(__FILE__), 'env'))
require 'active_model'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/hash/except'
require 'active_support/inflector'
require 'ostruct'
require 'delegate'
require 'braintree'
require 'braintree/exceptions'

require 'braintree_rails/attributes'
require 'braintree_rails/persistence'
require 'braintree_rails/model'
require 'braintree_rails/exceptions'
require 'braintree_rails/address'
require 'braintree_rails/addresses'
require 'braintree_rails/credit_card'
require 'braintree_rails/credit_cards'
require 'braintree_rails/customer'
require 'braintree_rails/transaction'
require 'braintree_rails/transactions'

module BraintreeRails
  def self.use_relative_model_naming?
    true
  end
end