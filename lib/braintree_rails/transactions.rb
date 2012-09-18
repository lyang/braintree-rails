module BraintreeRails
  class Transactions < SimpleDelegator
    def initialize(customer, credit_card=nil)
      @customer = customer || Customer.new({})
      @credit_card = credit_card || customer.credit_cards.find(&:default?)
      transactions = Braintree::Transaction.search do |search|
        search.customer_id.is @customer.id
        search.payment_method_token.is credit_card.token if credit_card && credit_card.persisted?
      end
      super transactions.to_a.map{ |t| Transaction.new(t) }
    end

    def find(id = nil, &block)
      id.nil? ? super(&block) : super() { |t| t.id == id }
    end

    def build(params)
      Transaction.new(params.reverse_merge(:customer => @customer, :credit_card => @credit_card))
    end

    def create(params)
      build(params).tap { |transaction| transaction.save }
    end

    def create!(params)
      build(params).tap { |transaction| transaction.save! }
    end
  end
end