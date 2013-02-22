module BraintreeRails
  class Discounts < SimpleDelegator
    include Association

    def initialize(plan, discounts)
      @plan = plan
      super(discounts)
    end

    def default_options
      {:plan_id => @plan.id}
    end
  end
end

