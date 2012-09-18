module BraintreeRails
  class Transaction < SimpleDelegator
    Attributes = [:id, :amount, :tax_amount, :tax_exempt, :customer, :order_id, :purchase_order_number, :credit_card, :vault_customer, :vault_credit_card, :billing, :shipping, :custom_fields, :descriptor, :options, :created_at, :updated_at].freeze
    include Model
    
    validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
    validates_each :customer do |record, attribute, value|
      if value.blank?
        record.errors.add(attribute, "is required.")
      else
        record.errors.add(attribute, "is not valid. #{value.errors.full_messages.join("\n")}") unless value.valid?
      end
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
      @credit_card = CreditCard.new(val).tap {|credit_card| self.billing ||= credit_card.billing_address}
    end

    def billing=(val)
      @billing = Address.new(val).tap {|billing| self.shipping ||= billing}
    end

    def shipping=(val)
      @shipping= Address.new(val)
    end

    [:submit_for_settlement!, :refund!, :void!].each do |method_with_exception|
      define_method method_with_exception do |*args|
        raise RecordInvalid.new("cannot #{method_with_exception} transactions not saved") if new_record?
        !!with_update_braintree {Braintree::Transaction.send(method_with_exception, *args.unshift(id))}
      end
    end

    [:submit_for_settlement, :refund, :void].each do |method_without_exception|
      define_method method_without_exception do |*args|
        begin
          raise RecordInvalid.new("cannot #{method_with_exception} transactions not saved") if new_record?
          !!with_update_braintree {Braintree::Transaction.send(method_without_exception, *args.unshift(id))}
        rescue RecordInvalid => e
          errors.add(:base, e.message)
          false
        end
      end
    end

    protected
    def create
      with_update_braintree do
        Braintree::Transaction.sale(attributes_for_sale)
      end
    end

    def create!
      with_update_braintree do
        Braintree::Transaction.sale!(attributes_for_sale)
      end
    end

    def attributes_for_sale
      attributes = attributes_for_update
      attributes.merge!(customer.persisted? ? {:customer_id => customer.id} : {:customer => customer.attributes_for_create})
      if credit_card.persisted?
        attributes.merge!(:payment_method_token => credit_card.id)
        attributes.delete(:billing)
      else
        attributes.merge!(:credit_card => credit_card.attributes_for_create.except(:billing_address))
      end
      attributes
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

    def attributes_to_exclude_from_update
      [:id, :customer, :credit_card, :vault_customer, :vault_credit_card, :created_at, :updated_at]
    end
  end
end