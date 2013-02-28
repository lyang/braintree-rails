module BraintreeRails
  class Modifications < SimpleDelegator
    include Association
    not_supported_apis(:build)

    def initialize(parent)
      super(parent.__getobj__.send(self.class.name.demodulize.underscore))
    end
  end
end
