module BraintreeRails
  class CreditCards < SimpleDelegator
    include Association

    def initialize(customer)
      @customer = customer
      super(customer.__getobj__.credit_cards)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
