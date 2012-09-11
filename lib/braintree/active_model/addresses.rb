module Braintree
  module ActiveModel
    class Addresses < SimpleDelegator
      def initialize(customer, addresses)
        @customer = customer
        super(Array(addresses).map{|address| Address.new(address)})
      end

      def find(id = nil, &block)
        id.nil? ? super(&block) : super() { |a| a.id == id }
      end

      def build(params)
        Address.new(params.merge(:customer_id => @customer.id))
      end
    end
  end
end