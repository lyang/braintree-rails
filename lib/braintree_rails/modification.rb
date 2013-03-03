module BraintreeRails
  class Modification < SimpleDelegator
    include Model

    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    define_attributes(
      :readonly => [
        :amount, :created_at, :description, :id, :kind, :merchant_id, :name,
        :never_expires, :number_of_billing_cycles, :quantity, :updated_at
      ]
    )

    def self.all
      braintree_model_class.all.map{ |modification| new(modification) }
    end
  end
end
