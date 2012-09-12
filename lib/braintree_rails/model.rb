module BraintreeRails
  module Model
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          extend ::ActiveModel::Naming
          include ::ActiveModel::Validations
          include ::ActiveModel::Serialization
          attr_accessor(*self::Attributes)
          delegate :each, :each_pair, :keys, :values, :[], :to => :attributes

          class << receiver
            alias :build :new
            
            def create(params)
              new(params).save
            end

            def create!(params)
              new(params).save!
            end

            def braintree_model_class
              "braintree/#{braintree_model_name}".camelize.constantize
            end

            def braintree_model_name
              name.demodulize.underscore
            end
          end
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

      def save
        create_or_update
      rescue RecordInvalid
        false
      end

      def save!
        create_or_update || raise(RecordNotSaved)
      end

      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end

      def update_attributes!(attributes)
        assign_attributes(attributes)
        save!
      end

      private
      def create_or_update
        !!(new_record? ? create : update)
      end

      def create
        with_update_braintree do
          self.class.braintree_model_class.create(attributes)
        end
      end

      def create!
        with_update_braintree do
          self.class.braintree_model_class.create!(attributes)
        end
      end

      def update
        with_update_braintree do
          self.class.braintree_model_class.update(self.id, self.attributes.except(:id))
        end
      end

      def update!
        with_update_braintree do
          self.class.braintree_model_class.update!(self.id, self.attributes.except(:id))
        end
      end

      def extract_values(obj)
        self.class::Attributes.inject({}) do |hash, attr|
          hash[attr] = obj.send(attr) if obj.respond_to?(attr)
          hash
        end
      end

      def assign_attributes(hash)
        hash.each do |attribute, value|
          send("#{attribute}=", value) if respond_to?("#{attribute}=")
        end
      end

      def add_errors(validation_errors)
        validation_errors.each do |error|
          if respond_to?(error.attribute)
            self.errors.add error.attribute, error.message
          else
            self.error.add :base, error.message
          end
        end
      end

      def with_update_braintree
        raise RecordInvalid unless valid?
        result = yield
        if result.respond_to?(:success?) && !result.success?
          add_errors(result.errors)
          false
        else
          new_record = result.respond_to?(self.class.braintree_model_name) ? result.send(self.class.braintree_model_name) : result
          assign_attributes(extract_values(new_record))
          @persisted = true
          self.__setobj__(new_record)
        end
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end