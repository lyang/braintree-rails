module BraintreeRails
  class IndividualDetailsValidator < Validator
    Validations = [
      [:first_name, :last_name, :email, :date_of_birth, :address, :presence => true]
    ]

    def validate(individual)
      validate_association(individual, :address)
    end
  end
end
