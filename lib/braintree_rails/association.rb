module BraintreeRails
  module Association
    module ClassMethods
      def lazy_load(methods)
        methods.each do |method|
          define_method method do |*args, &block|
            load!
            super(*args, &block)
          end
        end
      end
    end

    module InstanceMethods
      def initialize(models)
        super(Array(models).map{|model| model_class.new(model)})
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
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
