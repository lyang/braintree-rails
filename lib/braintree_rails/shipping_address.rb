module BraintreeRails
  class ShippingAddress < Address
    def self.braintree_model_name
      superclass.braintree_model_name
    end
  end
end
