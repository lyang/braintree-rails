module BraintreeRails
  class Error < StandardError; end
  class NotSupportedApiException < Error; end
  class RecordInvalid < Braintree::BraintreeError
    attr_reader :record
    def initialize(record)
      @record = record
      super(@record.errors.full_messages.join(", "))
    end
  end
end
