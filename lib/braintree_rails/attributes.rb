module BraintreeRails
  module Attributes
    module ClassMethods
      def self.extended(receiver)
        class << receiver; attr_accessor :attributes, :attributes_to_exclude; end
      end

      def define_attributes(*attributes)
        self.attributes = attributes
        attr_accessor(*attributes)
      end

      def exclude_attributes_from(exclusions)
        self.attributes_to_exclude ||= {}
        self.attributes_to_exclude.merge!(exclusions)
      end
    end

    module InstanceMethods
      def attributes
        self.class.attributes.inject({}) do |hash, attribute|
          value = self.send(attribute)
          hash[attribute] =  value if value.present?
          hash
        end
      end

      def attributes_for(action)
        attributes.except(*self.class.attributes_to_exclude[action]).tap do |hash|
          hash.each_pair do |key, value|
            hash[key] = value.attributes_for(action) if value.respond_to?(:attributes_for)
          end
        end
      end

      def assign_attributes(hash)
        hash.each do |attribute, value|
          send("#{attribute}=", value) if respond_to?("#{attribute}=")
        end
      end

      def extract_values(obj)
        return {} if obj.nil?
        self.class.attributes.inject({}) do |hash, attr|
          hash[attr] = obj.send(attr) if obj.respond_to?(attr)
          hash
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, ::ActiveModel::Serialization

      receiver.exclude_attributes_from(:update => [:id, :created_at, :updated_at], :create => [:created_at, :updated_at])
    end
  end
end