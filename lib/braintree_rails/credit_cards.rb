module BraintreeRails
  class CreditCards < SimpleDelegator
    include Association

    def initialize(customer, credit_cards)
      @customer = customer
      super(credit_cards)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
