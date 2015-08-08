module BraintreeRails
  class AddressDetails
    include Model

    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    define_attributes(:as_association => [:street_address, :locality, :region, :postal_code])

    def self.braintree_model_name
      "merchant_account/#{name.demodulize.underscore}"
    end

    def extract_errors(errors)
      errors.for(:address) if errors
    end
  end
end
