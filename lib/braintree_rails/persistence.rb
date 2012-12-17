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

      def save
        create_or_update
      rescue RecordInvalid
        false
      end

      def save!
        create_or_update!
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
          self.class.braintree_model_class.delete(id)
        end
        self.persisted = false unless frozen?
        freeze
      end
      alias :delete :destroy
      alias :delete! :destroy
      alias :destroy! :destroy

      protected
      def create_or_update
        !!(new_record? ? create : update)
      end

      def create_or_update!
        !!(new_record? ? create! : update!)
      end

      def create
        with_update_braintree do
          self.class.braintree_model_class.create(attributes_for(:create))
        end
      end

      def create!
        with_update_braintree do
          self.class.braintree_model_class.create!(attributes_for(:create))
        end
      end

      def update
        with_update_braintree do
          self.class.braintree_model_class.update(id, attributes_for(:update))
        end
      end

      def update!
        with_update_braintree do
          self.class.braintree_model_class.update!(id, attributes_for(:update))
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
          self.persisted = true
          self.__setobj__(new_record)
        end
      end
    end

    def self.included(receiver)
      receiver.class_eval { attr_accessor :persisted }
      receiver.instance_eval { alias :build :new }
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
