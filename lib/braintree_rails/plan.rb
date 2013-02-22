module BraintreeRails
  class Plan < SimpleDelegator
    include Model
    define_attributes(:id, :billing_day_of_month, :billing_frequency, :currency_iso_code, :description, :name, :number_of_billing_cycles, :price, :trial_duration, :trial_duration_unit, :trial_period, :created_at, :updated_at)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    attr_reader :add_ons

    def self.all
      @all ||= Braintree::Plan.all.map { |p| new(p) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def initialize(plan)
      plan = ensure_model(plan)
      set_add_ons(plan)
      super(plan)
    end

    def set_add_ons(plan)
      @add_ons = AddOns.new(self, plan.add_ons)
    end
  end
end
