module BraintreeRails
  class AddOns < SimpleDelegator
    include Association

    def initialize(plan, add_ons)
      @plan = plan
      super(add_ons)
    end

    def default_options
      {:plan_id => @plan.id}
    end
  end
end
