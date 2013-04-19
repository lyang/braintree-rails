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
          if (value = self.send(attribute)).present?
            hash[attribute] = value.respond_to?(:attributes_for) ? value.attributes_for(:as_association) : value
          end
          hash
        end
      end

      def attributes_for(action)
        attributes_for_action = attributes.slice(*self.class.attributes_for(action))
        attributes_for_action.slice!(*changed) unless action == :as_association
        attributes_for_action
      end

      def assign_attributes(hash)
        hash.each do |attribute, value|
          send("#{attribute}=", value) if respond_to?("#{attribute}=")
        end
      end

      def extract_values(obj)
        self.class.attributes.inject({}) do |hash, attr|
          hash[attr] = obj.send(attr) if obj.respond_to?(attr)
          hash
        end
      end

      def changed
        new_record? ? changed_for_new_record : changed_for_persisted
      end

      def changed_for_new_record
        attributes.map do |attribute, value|
          attribute if value.present?
        end.compact
      end

      def changed_for_persisted
        attributes.map do |attribute, value|
          attribute if !raw_object.respond_to?(attribute) || value != raw_object.send(attribute)
        end.compact
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :include, ::ActiveModel::Serializers::JSON
      receiver.send :include, ::ActiveModel::Serializers::Xml
    end
  end
end
