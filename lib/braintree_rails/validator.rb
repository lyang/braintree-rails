module BraintreeRails
  class Validator < ActiveModel::Validator
    def self.setup
      model_class.class_eval do
        reset_callbacks(:validate)
        validator_class::Validations.deep_dup.each do |validation|
          validates(*validation)
        end
      end
    end

    def self.model_class
      name.chomp('Validator').constantize
    end

    def setup(*)
      self.class.setup
    end

    def validate(record);end
  end
end
