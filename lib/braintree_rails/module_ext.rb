class Module
  def not_supported_apis(*methods)
    methods.each do |method|
      define_method(method) {|*args| raise BraintreeRails::NotSupportedApiException}
    end
  end

  def cattr_accessor(*attributes)
    singleton_class.class_eval do
      attr_accessor(*attributes)
    end
  end
end
