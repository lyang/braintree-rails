module BraintreeRails
  class Transaction < SimpleDelegator
    Attributes = [:amount, :customer, :credit_card, :vault_customer, :vault_credit_card, :created_at, :updated_at].freeze
    include Model
    
    validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}, :if => :new_record?
    validates_each :credit_card, :customer do |record, attribute, value|
      record.errors.add(attribute, "is not persisted") unless (value && value.persisted?)
    end
    
    class << self; undef_method :delete; end

    undef_method :update_attributes, :update_attributes!, :delete, :delete!, :destroy, :destroy!, :update, :update!

    def initialize(transaction = {})
      transaction = ensure_transaction(transaction)
      assign_attributes(extract_values(transaction))
      super
    end

    def vault_customer=(val)
      @vault_customer = self.customer = val
    end

    def vault_credit_card=(val)
      @vault_credit_card = self.credit_card = val
    end

    def customer=(val)
      @customer = Customer.new(val).tap {|customer| self.credit_card ||= customer.credit_cards.find(&:default?)}
    end

    def credit_card=(val)
      @credit_card = CreditCard.new(val)
    end

    [:submit_for_settlement!, :refund!, :void!].each do |method_with_exception|
      method_without_exception = method_with_exception.to_s.gsub(/!$/, '')
      
      define_method method_with_exception do |*args|
        raise RecordInvalid.new("You can only #{method_without_exception} an existing transaction") if new_record?
        with_update_braintree do
          Braintree::Transaction.send(method_with_exception, *args.unshift(id))
        end
      end
      
      define_method method_without_exception do |*args|
        begin
          self.send(method_with_exception, *args)
        rescue RecordInvalid => e
          errors.add(:base, e.message)
          return false
        end
      end
    end

    protected
    def create
      with_update_braintree do
        Braintree::Transaction.sale(attributes_for_create)
      end
    end

    def create!
      with_update_braintree do
        Braintree::Transaction.sale!(attributes_for_create)
      end
    end

    def attributes_for_create
      {:amount => amount, :customer_id => customer.id, :payment_method_token => credit_card.id }
    end

    def ensure_transaction(transaction)
      case transaction
      when String
        @persisted = true
        Braintree::Transaction.find(transaction)
      when Braintree::Transaction
        @persisted = true
        transaction
      when Hash
        @persisted = false
        OpenStruct.new(transaction.reverse_merge(:credit_card_details => nil, :transaction_details => nil, :subscription_details => nil))
      else
        @persisted = transaction.respond_to?(:persisted?) ? transaction.persisted? : false
        transaction
      end
    end
  end
end