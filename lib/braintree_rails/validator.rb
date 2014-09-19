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

    def initialize(*)
      self.class.setup
    end

    def validate(record)
    end

    def validate_association(record, name)
      record.instance_eval do
        association = record.send(name)
        return unless association.present?
        if association.invalid?
          errors.add(name, "is invalid")
          association.errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end
      end
    end
  end
end
