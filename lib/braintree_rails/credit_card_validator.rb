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
        validates :cardholder_name, :length => {:maximum => 255}
        with_options :presence => true do |credit_card|
          credit_card.validates :customer_id, :length => {:maximum => 36}, :if => :new_record?
          credit_card.validates :number, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, 'braintree_rails/luhn_10' => true, :if => Proc.new { |credit_card| CreditCardValidator.validate_number?(credit_card) }
          credit_card.validates :cvv, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }, :if => Proc.new { |credit_card| CreditCardValidator.validate_cvv?(credit_card) }
          credit_card.with_options :numericality => { :only_integer => true }, :if => Proc.new { |credit_card| CreditCardValidator.validate_expiration_date?(credit_card) } do |credit_card|
            credit_card.validates :expiration_month, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
            credit_card.validates :expiration_year, :numericality => { :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }
          end
        end
      end
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
