module BraintreeRails
  class Modification < SimpleDelegator
    include Model

    define_attributes(:amount, :created_at, :description, :id, :kind, :merchant_id, :name, :never_expires, :number_of_billing_cycles, :quantity, :updated_at)

    not_supported_apis(:create, :create!, :update, :update!, :destroy)
  end
end
