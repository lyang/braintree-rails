module BraintreeRails
  class Addresses < SimpleDelegator
    include Association

    def initialize(customer, addresses)
      @customer = customer
      super(addresses)
    end

    def default_options
      {:customer_id => @customer.id}
    end
  end
end
