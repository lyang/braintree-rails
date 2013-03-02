module BraintreeRails
  class CreditCard < SimpleDelegator
    include Model
    define_attributes(
      :create => [:billing_address, :cardholder_name, :customer_id, :expiration_date, :number, :cvv, :options, :token],
      :update => [:billing_address, :cardholder_name, :expiration_date, :options],
      :readonly => [
        :bin, :card_type, :commercial, :country_of_issuance, :created_at, :debit, :durbin_regulated, :expiration_month,
        :expiration_year, :healthcare, :issuing_bank, :last_4, :payroll, :prepaid, :unique_number_identifier, :updated_at
      ],
      :as_association => [:token, :cardholder_name, :cvv, :expiration_date, :expiration_month, :expiration_year, :number]
    )

    define_associations(:transactions, :subscriptions, :customer => :customer_id)

    with_options :presence => true, :if => :new_record? do |credit_card|
      credit_card.validates :customer_id, :length => {:maximum => 36}
      credit_card.validates :number, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}
      credit_card.validates :cvv, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }
      credit_card.validates_with Luhn10Validator, :attribute => :number
    end

    validates :cardholder_name, :length => {:maximum => 255}
    validates :expiration_month, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
    validates :expiration_year,  :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }
    validates :billing_address, :presence => true
    validates_each :billing_address do |record, attribute, value|
      record.errors.add(attribute, "is not valid. #{value.errors.full_messages.join("\n")}") if value && value.invalid?
    end

    def id
      token
    end

    def billing_address=(value)
      @billing_address = value && Address.new(value)
    end

    def expiration_date=(date)
      expiration_month, expiration_year = date.to_s.split('/')
      self.expiration_month = expiration_month
      self.expiration_year = expiration_year.to_s.gsub(/\A(\d{2})\z/, '20\1')
    end

    def expiration_date
      expiration_month.present? ? "#{expiration_month}/#{expiration_year}" : nil
    end

    def add_errors(validation_errors)
      billing_address.add_errors(validation_errors.except(:base))
      super(validation_errors)
    end

    def attributes_for(action)
      super.tap { |attributes| attributes[:billing_address].merge!(:options => {:update_existing => true}) if action == :update }
    end
  end
end
