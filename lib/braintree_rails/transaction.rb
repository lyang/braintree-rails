module BraintreeRails
  class Transaction < SimpleDelegator
    include Model

    class << self; undef_method :delete; end
    not_supported_apis(:update, :update!, :destroy)

    define_attributes(:id, :amount, :tax_amount, :tax_exempt, :customer, :customer_details, :credit_card, :credit_card_details, :order_id, :purchase_order_number, :billing, :shipping, :custom_fields, :descriptor, :options, :created_at, :updated_at)

    exclude_attributes_from(:update => [:id, :customer, :credit_card, :customer_details, :credit_card_details, :created_at, :updated_at])

    validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

    validate do
      errors.add(:customer, "is required.") and return if customer.blank?
      errors.add(:customer, "is not valid. #{customer.errors.full_messages.join("\n")}") unless customer.valid?
    end

    def initialize(transaction = {})
      super(ensure_model(transaction))
      set_customer
      set_credit_card
    end

    def customer=(value)
      @customer = value && Customer.new(value)
    end

    def credit_card=(value)
      @credit_card = value && CreditCard.new(value)
    end

    [:submit_for_settlement, :submit_for_settlement!, :refund, :refund!, :void, :void!].each do |method|
      define_method method do |*args|
        raise RecordInvalid.new("cannot #{method} transactions not saved") if new_record?
        !!with_update_braintree {Braintree::Transaction.send(method, *args.unshift(id))}
      end
    end

    protected
    def set_customer
      self.customer ||= customer_details.try(:id) || customer_details
    end

    def set_credit_card
      self.credit_card ||= credit_card_details.try(:token) || credit_card_details
      self.credit_card ||= customer.credit_cards.find(&:default?) if customer.present?
    end

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
      attributes = attributes_for(:update)
      attributes.merge!(customer.persisted? ? {:customer_id => customer.id} : {:customer => customer.attributes_for(:create)})
      if credit_card.persisted?
        attributes.merge!(:payment_method_token => credit_card.id)
        attributes.delete(:billing)
      else
        attributes.merge!(:credit_card => credit_card.attributes_for(:create).except(:billing_address))
      end
      attributes
    end
  end
end
