module BraintreeRails
  module Attributes
    module ClassMethods
      def define_attributes(attributes)
        all_attributes = attributes.values.flatten.uniq
        attr_accessor(*all_attributes)
        singleton_class.send(:define_method, :attributes_for) { |action| attributes[action] }
        singleton_class.send(:define_method, :attributes) { all_attributes }
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
        attributes.slice(*self.class.attributes_for(action)).tap do |hash|
          hash.each_pair do |key, value|
            hash[key] = value.attributes_for(:as_association) if value.respond_to?(:attributes_for)
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
    end
  end
end
