module BraintreeRails
  class FundingDetails
    include Model

    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    define_attributes(
      :readonly => [:account_number_last_4],
      :as_association => [:destination, :email, :mobile_phone, :account_number, :routing_number]
    )

    def self.braintree_model_name
      "merchant_account/#{name.demodulize.underscore}"
    end
  end
end
