module BraintreeRails
  class Addresses < SimpleDelegator
    include Association

    def initialize(customer)
      @customer = customer
      super(customer.__getobj__.addresses)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
