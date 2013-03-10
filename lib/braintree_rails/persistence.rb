module BraintreeRails
  module Persistence
    module ClassMethods
      def create(params)
        new(params).tap { |new_record| new_record.save }
      end

      def create!(params)
        new(params).tap { |new_record| new_record.save! }
      end

      def find(id)
        new(braintree_model_class.find(id))
      end

      def delete(id)
        braintree_model_class.delete(id)
      end

      def braintree_model_class
        "braintree/#{braintree_model_name}".camelize.constantize
      end

      def braintree_model_name
        name.demodulize.underscore
      end
    end

    module InstanceMethods
      def persisted?
        !!persisted
      end

      def new_record?
        !persisted?
      end

      def save(*)
        run_callbacks :save do
          create_or_update
        end
      rescue RecordInvalid
        false
      end

      def save!(*)
        run_callbacks :save do
          create_or_update!
        end
      end

      def update_attributes(attributes)
        assign_attributes(attributes)
        save
      end

      def update_attributes!(attributes)
        assign_attributes(attributes)
        save!
      end

      def destroy
        if persisted?
          run_callbacks :destroy do
            self.class.delete(id)
          end
        end
        self.persisted = false unless frozen?
        freeze
      end

      def delete; destroy; end
      def delete!; destroy; end
      def destroy!; destroy; end

      protected
      def create_or_update
        !!(new_record? ? create : update)
      end

      def create_or_update!
        !!(new_record? ? create! : update!)
      end

      def create
        with_update_braintree(:create) do
          self.class.braintree_model_class.create(attributes_for(:create))
        end
      end

      def create!
        with_update_braintree(:create) do
          self.class.braintree_model_class.create!(attributes_for(:create))
        end
      end

      def update
        with_update_braintree(:update) do
          self.class.braintree_model_class.update(id, attributes_for(:update))
        end
      end

      def update!
        with_update_braintree(:update) do
          self.class.braintree_model_class.update!(id, attributes_for(:update))
        end
      end

      def with_update_braintree(context)
        raise RecordInvalid.new(self) unless valid?(context)
        run_callbacks context do
          result = yield
          if result.respond_to?(:success?) && !result.success?
            add_errors(extract_errors(result))
            false
          else
            new_record = result.respond_to?(self.class.braintree_model_name) ? result.send(self.class.braintree_model_name) : result
            assign_attributes(extract_values(new_record))
            self.persisted = true
            self.__setobj__(new_record)
          end
        end
      end

      def extract_errors(result)
        base_errors(result).merge(attribute_errors(result))
      end

      def base_errors(result)
        all_messages = result.message.split("\n")
        base_messages = all_messages - attribute_errors(result).values
        {'base' => base_messages.join("\n")}
      end

      def attribute_errors(result)
        result.errors.inject({}) do |hash, error|
          next hash if error.attribute.to_s == 'base'
          hash[error.attribute.to_s] = error.message
          hash
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ActiveModel::Callbacks
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        attr_accessor :persisted
        define_model_callbacks :save, :create, :update, :destroy
      end
    end
  end
end
