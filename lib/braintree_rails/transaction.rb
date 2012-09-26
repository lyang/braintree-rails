module BraintreeRails
  class Transaction < SimpleDelegator
    include Model
    define_attributes(:id, :amount, :tax_amount, :tax_exempt, :customer, :order_id, :purchase_order_number, :credit_card, :vault_customer, :vault_credit_card, :credit_card_details, :billing, :shipping, :custom_fields, :descriptor, :options, :created_at, :updated_at)
    
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
      super(ensure_model(transaction))
      freeze if persisted?
    end

    def vault_customer=(val)
      @vault_customer = val.tap { self.customer ||= val }
    end

    def vault_credit_card=(val)
      @vault_credit_card = val.tap { self.credit_card ||= val }
    end

    def credit_card_details=(val)
      @credit_card_details = val.tap { self.credit_card ||= val }
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

    [:submit_for_settlement, :submit_for_settlement!, :refund, :refund!, :void, :void!].each do |method|
      define_method method do |*args|
        raise RecordInvalid.new("cannot #{method} transactions not saved") if new_record?
        !!with_update_braintree {Braintree::Transaction.send(method, *args.unshift(id))}
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

    def attributes_to_exclude_from_update
      [:id, :customer, :credit_card, :vault_customer, :vault_credit_card, :credit_card_details, :created_at, :updated_at]
    end
  end
end