module Braintree
  module ActiveModel
    module BraintreeModel
      module ClassMethods
        def self.extended(receiver)
          receiver.class_eval do
            extend ::ActiveModel::Naming
            include ::ActiveModel::Validations
            include ::ActiveModel::Serialization
            attr_accessor(*self::Attributes)
            delegate :each, :each_pair, :keys, :values, :[], :to => :attributes
          end
        end   
      end
      
      module InstanceMethods
        def persisted?
          @persisted
        end

        def new_record?
          !persisted?
        end

        def to_key
          persisted? ? [id] : nil
        end

        def to_param
          to_key.join("-")
        end

        def attributes
          self.class::Attributes.inject({}) do |hash, attribute|
            value = self.send(attribute)
            hash[attribute] =  value if value.present?
            hash
          end
        end

        def extract_values(obj)
          self.class::Attributes.inject({}) do |hash, attr|
            hash[attr] = obj.send(attr) if obj.respond_to?(attr)
            hash
          end
        end

        def write_attributes(hash)
          hash.each do |attribute, value|
            send("#{attribute}=", value) if respond_to?("#{attribute}=")
          end
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end