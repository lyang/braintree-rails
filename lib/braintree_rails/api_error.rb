module BraintreeRails
  class ApiError
    attr_reader :message, :code

    delegate :to_s, :empty?, :to => :message

    def initialize(message, code)
      @message, @code = message, code
    end

    def inspect
      "#<#{self.class} (#{code}) #{message}>"
    end
  end
end