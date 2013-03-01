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

    def add_ons
      @add_ons ||= AddOns.new(self)
    end

    def discounts
      @discounts ||= Discounts.new(self)
    end
  end
end
