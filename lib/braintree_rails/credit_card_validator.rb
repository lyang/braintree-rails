module BraintreeRails
  class CreditCardValidator < Validator
    Validations = [
      [:cardholder_name, :length => {:maximum => 255}],
      [:customer_id, :presence => true, :length => {:maximum => 36}, :if => :new_record?],
      [:number, :presence => true, :if => :new_record?],
      [:number, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, 'braintree_rails/luhn_10' => true, :if => Proc.new { |credit_card| CreditCardValidator.validate_number?(credit_card) }],
      [:cvv, :presence => true, :if => :new_record?],
      [:cvv, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_cvv?(credit_card) }],
      [:expiration_month, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_date.blank? }],
      [:expiration_year, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_date.blank? }],
      [:expiration_date, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_month.blank? }],
      [:expiration_month, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_expiration_date?(credit_card) }],
      [:expiration_year, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_expiration_date?(credit_card) }],
    ]

    def self.validate_number?(credit_card)
      Configuration.mode == Configuration::Mode::S2S
    end

    def self.validate_cvv?(credit_card)
      Configuration.mode == Configuration::Mode::S2S
    end

    def self.validate_expiration_date?(credit_card)
      Configuration.mode == Configuration::Mode::S2S
    end

    def self.validate_billing_address?(credit_card)
      Configuration.require_postal_code || Configuration.require_street_address
    end

    def validate(credit_card)
      have_valid_billing_address(credit_card) if self.class.validate_billing_address?(credit_card)
    end

    def have_valid_billing_address(credit_card)
      credit_card.instance_eval do
        errors.add(:billing_address, "is empty.") and return if billing_address.blank?
        errors.add(:billing_address, "is not valid. #{billing_address.errors.full_messages.join("\n")}") if billing_address.invalid?
      end
    end
  end
end
