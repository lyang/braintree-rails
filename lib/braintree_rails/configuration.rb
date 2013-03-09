module BraintreeRails
  class Configuration

    module Mode
      JS = 'JS'
      S2S = 'S2S'
      TR = 'TR'
    end

    delegate :environment, :merchant_id, :public_key, :private_key, :logger, :to => 'Braintree::Configuration'
    delegate :environment=, :merchant_id=, :public_key=, :private_key=, :logger=, :to => 'Braintree::Configuration'

    cattr_accessor :mode, :require_postal_code, :require_street_address
    self.mode = Mode::JS
    self.require_postal_code = true
    self.require_street_address = true
  end
end
