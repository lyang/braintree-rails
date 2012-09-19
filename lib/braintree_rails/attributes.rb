module BraintreeRails
  module Attributes
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          include ::ActiveModel::Serialization
          attr_accessor(*self::Attributes)
        end
      end
    end

    module InstanceMethods
      def attributes
        self.class::Attributes.inject({}) do |hash, attribute|
          value = self.send(attribute)
          hash[attribute] =  value if value.present?
          hash
        end
      end

      def attributes_for_update
        attributes.except(*attributes_to_exclude_from_update).tap do |hash|
          hash.each_pair do |key, value|
            hash[key] = value.attributes_for_update if value.respond_to?(:attributes_for_update)
          end
        end
      end

      def attributes_for_create
        attributes.except(*attributes_to_exclude_from_create).tap do |hash|
          hash.each_pair do |key, value|
            hash[key] = value.attributes_for_create if value.respond_to?(:attributes_for_create)
          end
        end
      end

      def assign_attributes(hash)
        hash.each do |attribute, value|
          send("#{attribute}=", value) if respond_to?("#{attribute}=")
        end
      end

      def attributes_to_exclude_from_update
        [:id, :created_at, :updated_at]
      end

      def attributes_to_exclude_from_create
        [:created_at, :updated_at]
      end
      
      def extract_values(obj)
        return {} if obj.nil?
        self.class::Attributes.inject({}) do |hash, attr|
          hash[attr] = obj.send(attr) if obj.respond_to?(attr)
          hash
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end