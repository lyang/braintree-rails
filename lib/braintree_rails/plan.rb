module BraintreeRails
  class Plan < SimpleDelegator
    include Model

    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    define_attributes(
      :readonly => [
        :billing_day_of_month, :billing_frequency, :created_at, :currency_iso_code, :description, :id, :merchant_id, :name,
        :number_of_billing_cycles, :price, :trial_duration, :trial_duration_unit, :trial_period, :updated_at
      ]
    )

    define_associations(:add_ons, :discounts, :subscriptions)

    def self.all
      braintree_model_class.all.map{ |plan| new(plan) }
    end
  end
end
