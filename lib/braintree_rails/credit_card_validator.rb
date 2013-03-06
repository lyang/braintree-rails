module BraintreeRails
  class CreditCardValidator < ActiveModel::Validator
    def self.validate_number?(credit_card)
      credit_card.new_record?
    end

    def self.validate_cvv?(credit_card)
      credit_card.new_record?
    end

    def self.validate_expiration_date?(credit_card)
      true
    end

    def self.validate_billing_address?(credit_card)
      true
    end

    def setup(klass)
      klass.class_eval do
        validates :customer_id, :length => {:maximum => 36}, :presence => true, :if => :new_record?
        validates :cardholder_name, :length => {:maximum => 255}
        validates :number, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, 'braintree_rails/luhn_10' => true, :presence => true, :if => Proc.new { |credit_card| CreditCardValidator.validate_number?(credit_card) }
        validates :cvv, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }, :presence => true, :if => Proc.new { |credit_card| CreditCardValidator.validate_cvv?(credit_card) }
        validates :expiration_month, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_expiration_date?(credit_card) }
        validates :expiration_year,  :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_expiration_date?(credit_card) }
      end
    end

    def validate(credit_card)
      have_valid_billing_address(credit_card)
    end

    def have_valid_billing_address(credit_card)
      if self.class.validate_billing_address?(credit_card)
        credit_card.instance_eval do
          errors.add(:billing_address, "is empty.") and return if billing_address.blank?
          errors.add(:billing_address, "is not valid. #{billing_address.errors.full_messages.join("\n")}") if billing_address.invalid?
        end
      end
    end
  end
end
