module BraintreeRails
  module Association
    module ClassMethods
      def self.extended(receiver)
        receiver.class_eval do
          attr_accessor :collection, :loaded
          (Array.public_instance_methods - Object.public_instance_methods).each do |method|
            define_method(method) do |*args, &block|
              load!
              super(*args, &block)
            end
          end
        end
      end
    end

    module InstanceMethods
      def initialize(collection = [])
        super(self.collection = collection)
      end

      def find(id = nil, &block)
        id.nil? ? super(&block) : super() { |model| model.id == id }
      end

      def build(params = {})
        model_class.new(default_options.merge(params))
      end

      def create(params = {})
        build(params).tap { |model| push(model) if model.save }
      end

      def create!(params = {})
        build(params).tap { |model| push(model) if model.save! }
      end

      def model_class
        self.class.name.singularize.constantize
      end

      def load!
        return if loaded
        self.loaded = true
        __setobj__(collection.map{|model| model_class.new(model)})
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
