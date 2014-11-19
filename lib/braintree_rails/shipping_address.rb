module BraintreeRails
  class ShippingAddress < Address
    def self.braintree_model_name
      superclass.braintree_model_name
    end

    def extract_errors(errors)
      errors.for(:shipping_address) || errors.for(:shipping)
    end
  end
end