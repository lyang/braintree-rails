module BraintreeRails
  class CreditCard < SimpleDelegator
    include Model
    define_attributes(
      :create => [:billing_address, :cardholder_name, :customer_id, :expiration_date, :expiration_month, :expiration_year, :number, :cvv, :options, :token],
      :update => [:billing_address, :cardholder_name, :expiration_date, :expiration_month, :expiration_year, :options],
      :readonly => [
        :bin, :card_type, :commercial, :country_of_issuance, :created_at, :debit, :durbin_regulated, :expiration_month,
        :expiration_year, :healthcare, :issuing_bank, :last_4, :payroll, :prepaid, :unique_number_identifier, :updated_at
      ],
      :as_association => [:token, :cardholder_name, :cvv, :expiration_date, :expiration_month, :expiration_year, :number]
    )

    define_associations(:transactions, :subscriptions, :customer => :customer_id)

    after_save :clear_encryped_attributes

    def ensure_model(model)
      if Braintree::Transaction::CreditCardDetails === model && model.token.present?
        model = model.token
      end
      super
    end

    def id
      token
    end

    def billing_address=(value)
      @billing_address = value && Address.new(value)
    end

    def add_errors(validation_errors)
      billing_address.add_errors(validation_errors.except(:base))
      super(validation_errors)
    end

    def attributes_for(action)
      super.tap do |attributes|
        attributes[:billing_address].merge!(:options => {:update_existing => true}) if action == :update
        attributes.delete(:expiration_date) if expiration_month.present?
      end
    end

    def clear_encryped_attributes
      return unless Configuration.mode == Configuration::Mode::JS
      [:number=, :cvv=, :expiration_date=, :expiration_year=, :expiration_month=].each do |encrypted_attribute|
        self.send(encrypted_attribute, nil)
      end
    end
  end
end
