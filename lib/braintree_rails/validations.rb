module BraintreeRails
  module Validations
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          include ::ActiveModel::Validations
          validates_with validator_class
        end
      end

      def validator_class
        name.concat("Validator").constantize
      end
    end

    module InstanceMethods
      def save(options = {})
        perform_validations(options) ? super : false
      end

      def save!(options = {})
        perform_validations(options) ? super : raise(RecordInvalid.new(self))
      end

      def perform_validations(options={})
        perform_validation = options[:validate] != false
        perform_validation ? valid?(options[:context]) : true
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
