module BraintreeRails
  class Validator < ActiveModel::Validator
    def self.setup(&block)
      reset_validations
      set_validations(collect_validations(&block))
    end

    def self.reset_validations
      model_class.reset_callbacks(:validate)
    end

    def self.set_validations(validations)
      validations.each do |validation|
        model_class.validates(*validation)
      end
    end

    def self.default_validations
      self::Validations.deep_dup
    end

    def self.collect_validations(&block)
      block.present? ? block.call(default_validations) : default_validations
    end

    def self.model_class
      name.chomp('Validator').constantize
    end

    def setup(*)
      self.class.setup
    end

    def validate(record)
    end
  end
end
