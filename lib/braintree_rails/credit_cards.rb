module BraintreeRails
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

    def create(params)
      build(params).tap { |credit_card| credit_card.save }
    end

    def create!(params)
      build(params).tap { |credit_card| credit_card.save! }
    end
  end
end
