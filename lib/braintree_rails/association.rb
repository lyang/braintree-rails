module BraintreeRails
  module Association
    def initialize(models)
      super(Array(models).map{|model| model_class.new(model)})
    end

    def find(id = nil, &block)
      id.nil? ? super(&block) : super() { |model| model.id == id }
    end

    def build(params)
      model_class.new(params.merge(default_options))
    end

    def create(params)
      build(params).tap { |model| push(model) if model.save }
    end

    def create!(params)
      build(params).tap { |model| push(model) if model.save! }
    end

    def model_class
      self.class.name.singularize.constantize
    end
  end
end