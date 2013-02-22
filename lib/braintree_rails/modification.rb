module BraintreeRails
  class Modification < SimpleDelegator
    include Model
    define_attributes(:id, :name, :description, :amount, :quantity, :number_of_billing_cycles, :never_expires, :created_at, :updated_at)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def self.all
      @all ||= braintree_model_class.all.map { |model| new(model) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def initialize(modification)
      super(ensure_model(modification))
    end

    def ensure_model(model)
      model = case model
      when String
        self.persisted = true
        self.class.find(model)
      else
        super(model)
      end
      assign_attributes(extract_values(model))
      model
    end
  end
end
