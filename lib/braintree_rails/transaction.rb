module BraintreeRails
  class Transaction < SimpleDelegator
    include Model
    singleton_class.not_supported_apis(:delete)
    not_supported_apis(:update, :update!, :destroy)

    define_attributes(
      :create => [
        :amount, :billing, :channel, :custom_fields, :customer_id, :descriptor, :merchant_account_id,
        :options, :order_id, :payment_method_token, :purchase_order_number, :recurring, :shipping, :shipping_address_id,
        :tax_amount, :tax_exempt, :type, :venmo_sdk_payment_method_code
      ],
      :readonly => [
        :avs_error_response_code, :avs_postal_code_response_code, :avs_street_address_response_code, :billing_details,
        :channel, :created_at, :credit_card, :credit_card_details, :currency_iso_code, :customer, :customer_details,
        :cvv_response_code, :plan_id, :purchase_order_number, :refund_ids, :refunded_transaction_id, :settlement_batch_id,
        :shipping_details, :status, :status_history, :subscription_details, :updated_at
      ]
    )

    validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

    validate do
      errors.add(:base, "Either customer or credit card is required.") and return if customer.blank? && credit_card.blank?
      errors.add(:customer, "does not have a default credit card.") if credit_card.blank? && customer.default_credit_card.blank?
    end

    [:submit_for_settlement, :submit_for_settlement!, :refund, :refund!, :void, :void!].each do |method|
      define_method method do |*args|
        raise RecordInvalid.new("cannot #{method} transactions not saved") if new_record?
        !!with_update_braintree {Braintree::Transaction.send(method, *args.unshift(id))}
      end
    end

    def customer=(val)
      @customer = val && Customer.new(val)
    end

    def customer
      @customer ||= customer_details.try(:id) && Customer.new(customer_details.id)
    end

    def credit_card=(val)
      @credit_card = val && CreditCard.new(val)
    end

    def credit_card
      @credit_card ||= credit_card_details.try(:token) && CreditCard.new(credit_card_details.token)
    end

    def add_ons
      @add_ons ||= AddOns.new(self)
    end

    def discounts
      @discounts ||= Discounts.new(self)
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
      attributes = attributes_for(:create)
      attributes.merge!(customer_attributes).merge!(credit_card_attributes)
      attributes.delete(:billing) if credit_card.present? && credit_card.persisted?
      attributes
    end

    def customer_attributes
      if customer.present?
        if customer.persisted?
          {:customer_id => customer.id}
        else
          {:customer => customer.attributes_for(:create)}
        end
      else
        {}
      end
    end

    def credit_card_attributes
      if credit_card.present?
        if credit_card.persisted?
          {:payment_method_token => credit_card.token}
        else
          {:credit_card => credit_card.attributes_for(:create).except(:billing_address)}
        end
      else
        {:payment_method_token => customer.default_credit_card.token}
      end
    end
  end
end
