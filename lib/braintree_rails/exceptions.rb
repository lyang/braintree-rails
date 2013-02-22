module BraintreeRails
  class RecordInvalid < Braintree::BraintreeError; end
  class NotSupportedApiException < StandardError; end
end
