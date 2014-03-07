module BraintreeRails
  class IndividualDetails
    include Model

    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    define_attributes(
      :readonly => [:ssn_last_4],
      :as_association => [:first_name, :last_name, :email, :phone, :date_of_birth, :ssn, :address]
    )

    has_one :address, :class => AddressDetails

    def self.braintree_model_name
      "merchant_account/#{name.demodulize.underscore}"
    end

    def add_errors(validation_errors)
      address.add_errors(validation_errors) if address
      super(validation_errors)
    end

    def attributes_for(action)
      super.merge(address_attributes)
    end

    def address_attributes
      address.present? ? {:address => address.attributes_for(:as_association)} : {}
    end
  end
end
