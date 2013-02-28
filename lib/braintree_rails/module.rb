class Module
  def not_supported_apis(*methods)
    methods.each do |method|
      define_method(method) {|*args| raise BraintreeRails::NotSupportedApiException}
    end
  end
end
