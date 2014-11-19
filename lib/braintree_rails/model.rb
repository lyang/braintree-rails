module BraintreeRails
  def self.use_relative_model_naming?
    true
  end

  module Model
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          attr_reader :raw_object
          extend ::ActiveModel::Naming
          include ::ActiveModel::Validations
          include ::ActiveModel::Conversion
        end
      end
    end

    module InstanceMethods
      def initialize(model = {})
        init(model)
      end

      def ensure_model(model)
        model = case model
        when String
          self.persisted = true
          self.class.braintree_model_class.find(model)
        when self.class.braintree_model_class
          self.persisted = model.id.present?
          model
        when Hash
          self.persisted = false
          OpenStruct.new(model)
        else
          self.persisted = model.respond_to?(:persisted?) ? model.persisted? : false
          model
        end
        assign_attributes(extract_values(model))
        model
      end

      def add_errors(validation_errors)
        Array(extract_errors(validation_errors)).each do |error|
          self.errors.add(error.attribute.to_sym, error.code.to_sym, message:BraintreeRails::ApiError.new(error.message, error.code))
        end
      end

      def extract_errors(validation_errors)
        validation_errors.for(self.class.braintree_model_name.to_sym)
      end

      def ==(other)
        return false unless other.is_a?(self.class) || other.is_a?(self.class.braintree_model_class)
        id == other.id
      end

      private

      def init(model)
        self.class.associations.each {|association| instance_variable_set("@#{association}", nil)}
        @raw_object = ensure_model(model)
      end
    end

    def self.included(receiver)
      receiver.send :include, BraintreeRails::Attributes
      receiver.send :include, BraintreeRails::Association
      receiver.send :include, BraintreeRails::Persistence
      receiver.send :include, BraintreeRails::Validations
      receiver.send :include, InstanceMethods
      receiver.extend         ClassMethods
    end
  end
end