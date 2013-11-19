module BraintreeRails
  class CustomerValidator < Validator
    Validations = [
      [:id, :format => {:with => /\A[-_a-z0-9]*\z/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}],
      [:first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}]
    ]

    def validate(customer)
      validate_credit_card(customer) if customer.credit_card.present?
    end

    def validate_credit_card(customer)
      customer.instance_eval do
        if credit_card.invalid?
          errors.add(:credit_card, "is invalid")
          credit_card.errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end
      end
    end
  end
end
