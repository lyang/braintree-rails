module BraintreeRails
  class Transactions < SimpleDelegator
    include CollectionAssociation

    def initialize(belongs_to)
      case belongs_to
      when BraintreeRails::Customer
        @customer = belongs_to
      when BraintreeRails::CreditCard
        @credit_card = belongs_to
      when BraintreeRails::Subscription
        @subscription = belongs_to
        self.singleton_class.not_supported_apis(:build)
      end
      super([])
    end

    def default_options
      if @credit_card.present?
        {:credit_card => @credit_card}
      elsif @customer.present?
        {:customer => @customer, :credit_card => @customer.default_credit_card}
      else
        {}
      end
    end

    protected
    def load!
      self.collection = if @subscription.present?
        @subscription.raw_object.transactions
      elsif @credit_card.present?
        Braintree::Transaction.search {|search| search.payment_method_token.is @credit_card.token}
      elsif @customer.present?
        Braintree::Transaction.search {|search| search.customer_id.is @customer.id}
      else
        Braintree::Transaction.search
      end
      super
    end
  end
end
