module BraintreeRails
  class Subscriptions < SimpleDelegator
    include Association

    def initialize(credit_card)
      @credit_card = credit_card
      super(credit_card.__getobj__.subscriptions)
    end

    def default_options
      {:payment_method_token => @credit_card.token}
    end
  end
end
