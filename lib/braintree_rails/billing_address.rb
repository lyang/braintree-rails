module BraintreeRails
  class BillingAddress < Address
    def self.braintree_model_name
      superclass.braintree_model_name
    end

    def extract_errors(errors)
      errors.for(:billing_address) || errors.for(:billing)
    end
  end
end