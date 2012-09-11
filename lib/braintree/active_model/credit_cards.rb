module Braintree
  module ActiveModel
    class CreditCards < SimpleDelegator
      def initialize(customer, credit_cards)
        @customer = customer
        super(Array(credit_cards).map{|card| CreditCard.new(card)})
      end

      def find(token = nil, &block)
        token.nil? ? super(&block) : super() { |c| c.token == token }
      end

      def build(params)
        CreditCard.new(params.merge(:customer_id => @customer.id))
      end
    end
  end
end