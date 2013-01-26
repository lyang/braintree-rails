module BraintreeRails
  class Transactions < SimpleDelegator
    include Association

    def initialize(customer, credit_card=nil)
      @customer = customer || Customer.new({})
      @credit_card = credit_card || @customer.credit_cards.find(&:default?)
      super([])
    end

    def default_options
      {:customer => @customer, :credit_card => @credit_card}
    end

    def each
      load_associated_transactions
      super
    end

    def length
      load_associated_transactions
      super
    end

    def count
      load_associated_transactions
      super
    end

    private
    def load_associated_transactions
      @result ||= Braintree::Transaction.search do |search|
        search.customer_id.is @customer.id
        search.payment_method_token.is @credit_card.token if @credit_card && @credit_card.persisted?
      end.to_a
      __setobj__(@result)
    end
  end
end
