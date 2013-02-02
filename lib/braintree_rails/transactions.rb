module BraintreeRails
  class Transactions < SimpleDelegator
    include Association
    lazy_load Array.public_instance_methods - Object.public_instance_methods

    def initialize(customer, credit_card=nil)
      @customer = customer || Customer.new({})
      @credit_card = credit_card || @customer.credit_cards.find(&:default?)
      super([])
    end

    def default_options
      {:customer => @customer, :credit_card => @credit_card}
    end

    protected
    def load!
      @result ||= Braintree::Transaction.search do |search|
        search.customer_id.is @customer.id
        search.payment_method_token.is @credit_card.token if @credit_card && @credit_card.persisted?
      end.map {|t| BraintreeRails::Transaction.new(t)}
      __setobj__(@result)
    end
  end
end
