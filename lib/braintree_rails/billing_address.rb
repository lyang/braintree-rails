module BraintreeRails
  class BillingAddress < Address
    def self.braintree_model_name
      superclass.braintree_model_name
    end
  end
end
