module BraintreeRails
  module Attributes
    module ClassMethods
      def define_attributes(attributes)
        all_attributes = attributes.values.flatten.uniq
        attr_accessor(*all_attributes)
        singleton_class.send(:define_method, :attributes_for) { |action| attributes[action] }
        singleton_class.send(:define_method, :attributes) { all_attributes }
      end

      def define_associations(*associations)
        associations.extract_options!.each do |option|
          name, fk, class_name = extract_from_options(option)
          define_association(name) do |instance|
            key = instance.send(fk)
            key && association_class(class_name).new(key)
          end
        end

        associations.each do |name|
          define_association(name) do |instance|
            association_class(name).new(instance)
          end
        end
      end

      def association_class(name)
        "braintree_rails/#{name}".camelize.constantize
      end

      def extract_from_options(option)
        name = class_name = option.shift
        if option.first.is_a?(Hash)
          class_name = option.first[:class_name]
          fk = option.first[:foreign_key]
        else
          fk = option.first
        end
        [name, fk, class_name]
      end

      def define_association(name, &block)
        define_method(name) do
          value = instance_variable_get("@#{name}")
          return value if value.present?
          instance_variable_set("@#{name}", block.call(self))
        end
      end
    end

    module InstanceMethods
      def attributes
        self.class.attributes.inject({}) do |hash, attribute|
          value = self.send(attribute)
          hash[attribute] = value if value.present?
          hash[attribute] = value.attributes_for(:as_association) if value.respond_to?(:attributes_for)
          hash
        end
      end

      def attributes_for(action)
        attributes.slice(*self.class.attributes_for(action))
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
      receiver.send :include, ::ActiveModel::Serializers::JSON
      receiver.send :include, ::ActiveModel::Serializers::Xml
    end
  end
end
