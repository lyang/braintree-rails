module Braintree
  module ActiveModel
    class Customer < SimpleDelegator
      Attributes = [:id, :first_name, :last_name, :email, :company, :website, :phone, :fax].freeze
      include BraintreeModel

      validates :id, :format => {:with => /^[-_a-z0-9]+$/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}
      validates :first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}

      def initialize(customer)
        customer = ensure_customer(customer)
        write_attributes(extract_values(customer))
        super
      end

      protected
      def ensure_customer(customer)
        case customer
        when String
          @persisted = true
          Braintree::Customer.find(customer)
        when Braintree::Customer
          @persisted = true
          customer
        when Hash
          @persisted = false
          OpenStruct.new(customer)
        end
      end
    end
  end
end