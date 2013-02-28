module BraintreeRails
  class Modification < SimpleDelegator
    include Model

    define_attributes(:amount, :created_at, :description, :id, :kind, :merchant_id, :name, :never_expires, :number_of_billing_cycles, :quantity, :updated_at)

    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def self.all
      @all ||= braintree_model_class.all.map { |model| new(model) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def ensure_model(model)
      model.is_a?(String) ? super(self.class.find(model)) : super
    end
  end
end
