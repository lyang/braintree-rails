module BraintreeRails
  class Plan < SimpleDelegator
    include Model

    define_attributes(
      :billing_day_of_month, :billing_frequency, :created_at, :currency_iso_code, :description, :id, :merchant_id,
      :name, :number_of_billing_cycles, :price, :trial_duration, :trial_duration_unit, :trial_period, :updated_at
    )

    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def add_ons
      @add_ons ||= AddOns.new(self)
    end

    def discounts
      @discounts ||= Discounts.new(self)
    end
  end
end
