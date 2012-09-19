module BraintreeRails
  module Model
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          extend ::ActiveModel::Naming
          include ::ActiveModel::Validations
        end
      end   
    end
    
    module InstanceMethods
      def to_key
        persisted? ? [id] : nil
      end

      def to_param
        to_key.join("-")
      end

      def add_errors(validation_errors)
        validation_errors.each do |error|
          if respond_to?(error.attribute)
            self.errors.add error.attribute, error.message
          else
            self.errors.add :base, error.message
          end
        end
      end
    end
    
    def self.included(receiver)
      receiver.send :include, BraintreeRails::Attributes
      receiver.send :include, BraintreeRails::Persistence
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end