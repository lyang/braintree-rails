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

      def reload
        init(self.class.braintree_model_class.find(id))
        self
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
            add_errors(result.errors)
            false
          else
            new_record = result.respond_to?(self.class.braintree_model_name) ? result.send(self.class.braintree_model_name) : result
            init(new_record)
          end
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ActiveModel::Callbacks
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.class_eval do
        attr_accessor :persisted
        define_model_callbacks :validate, :save, :create, :update, :destroy
      end
    end
  end
end