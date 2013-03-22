module BraintreeRails
  class CreditCards < SimpleDelegator
    include CollectionAssociation

    def initialize(customer)
      @customer = customer
      super(customer.raw_object.credit_cards)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
