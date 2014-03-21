module BraintreeRails
  class IndividualDetailsValidator < Validator
    Validations = [
      [:first_name, :last_name, :email, :date_of_birth, :address, :presence => true]
    ]

    def validate(individual)
      validate_address(individual) if individual.address.present?
    end

    def validate_address(individual)
      individual.instance_eval do
        if address.invalid?
          errors.add(:address, "is invalid")
          address.errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end
      end
    end
  end
end
