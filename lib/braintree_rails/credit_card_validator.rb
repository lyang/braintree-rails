module BraintreeRails
  class CreditCardValidator < ActiveModel::Validator
    def setup(klass)
      klass.class_eval do
        with_options :presence => true, :if => :new_record? do |credit_card|
          credit_card.validates :customer_id, :length => {:maximum => 36}
          credit_card.validates :number, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, 'braintree_rails/luhn_10' => true
          credit_card.validates :cvv, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }
        end
        validates :cardholder_name, :length => {:maximum => 255}
        validates :expiration_month, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
        validates :expiration_year,  :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }
        validates :billing_address, :presence => true
      end
    end

    def validate(credit_card)
      validate_billing_address(credit_card)
    end

    def validate_billing_address(credit_card)
      if credit_card.billing_address && credit_card.billing_address.invalid?
        credit_card.errors.add(:billing_address, "is not valid. #{credit_card.billing_address.errors.full_messages.join("\n")}")
      end
    end
  end
end
