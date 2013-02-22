module BraintreeRails
  class Plan < SimpleDelegator
    include Model
    define_attributes(:id, :billing_day_of_month, :billing_frequency, :currency_iso_code, :description, :name, :number_of_billing_cycles, :price, :trial_duration, :trial_duration_unit, :trial_period, :created_at, :updated_at)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def self.all
      @all ||= Braintree::Plan.all.map { |p| new(p) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def initialize(plan)
      super(ensure_model(plan))
    end
  end
end
