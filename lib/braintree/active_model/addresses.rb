module Braintree
  module ActiveModel
    class Addresses < SimpleDelegator
      def initialize(customer, addresses)
        @customer = customer
        super(Array(addresses).map{|address| Address.new(address)})
      end

      def build(params)
        Address.new(params.merge(:customer_id => @customer.id))
      end
    end
  end
end