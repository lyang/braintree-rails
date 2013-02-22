module BraintreeRails
  class AddOn < SimpleDelegator
    include Model
    define_attributes(:id, :name, :description, :amount, :quantity, :number_of_billing_cycles, :never_expires, :created_at, :updated_at)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def self.all
      @all ||= Braintree::AddOn.all.map { |a| new(a) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def initialize(add_on)
      super(ensure_model(add_on))
    end
  end
end

