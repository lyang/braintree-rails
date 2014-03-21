module BraintreeRails
  class AddressDetailsValidator < Validator
    Validations = [
      [:street_address, :locality, :region, :postal_code, :presence => true]
    ]
  end
end
