module BraintreeRails
  class CustomerValidator < Validator
    Validations = [
      [:id, :format => {:with => /\A[-_a-z0-9]*\z/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}],
      [:first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}]
    ]

    def validate(customer)
      validate_association(customer, :credit_card)
    end
  end
end
