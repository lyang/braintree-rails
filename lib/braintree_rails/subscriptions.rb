module BraintreeRails
  class Subscriptions < SimpleDelegator
    include CollectionAssociation

    def initialize(belongs_to)
      case belongs_to
      when BraintreeRails::CreditCard
        @credit_card = belongs_to
      when BraintreeRails::Plan
        @plan = belongs_to
      end
      super([])
    end

    def default_options
      if @credit_card.present?
        {:payment_method_token => @credit_card.token}
      elsif @plan.present?
        {:plan_id => @plan.id}
      else
        {}
      end
    end

    protected
    def load!
      self.collection = if @credit_card.present?
        @credit_card.raw_object.subscriptions
      elsif @plan.present?
        Braintree::Subscription.search {|search| search.plan_id.is @plan.id}
      else
        Braintree::Subscription.search
      end
      super
    end
  end
end
