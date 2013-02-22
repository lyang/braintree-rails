module BraintreeRails
  class Modifications < SimpleDelegator
    include Association

    def initialize(plan, modifications)
      @plan = plan
      super(modifications)
    end

    def default_options
      {:plan_id => @plan.id}
    end
  end
end
