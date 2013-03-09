module BraintreeRails
  class Validator < ActiveModel::Validator
    def setup(*)
      validations = self.class::Validations
      model_class.class_eval do
        _validators.clear()
        validations.each do |validation|
          validates(*validation)
        end
      end
    end

    def model_class
      self.class.name.chomp('Validator').constantize
    end

    def validate(record);end
  end
end
