module BraintreeRails
  class Discount < SimpleDelegator
    include Model
    define_attributes(:id, :name, :description, :amount, :quantity, :number_of_billing_cycles, :never_expires, :created_at, :updated_at)
    not_supported_apis(:create, :create!, :update, :update!, :destroy)

    def self.all
      @all ||= Braintree::Discount.all.map { |d| new(d) }
    end

    def self.find(id = nil, &block)
      id.nil? ? all.find(&block) : all.find { |model| model.id == id }
    end

    def initialize(discount)
      super(ensure_model(discount))
    end
  end
end


