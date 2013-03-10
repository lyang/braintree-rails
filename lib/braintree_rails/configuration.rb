module BraintreeRails
  class Configuration

    module Mode
      JS = 'JS'
      S2S = 'S2S'
      TR = 'TR'
    end

    singleton_class.class_eval do
      delegate :custom_user_agent, :environment, :merchant_id, :public_key, :private_key, :logger, :to => Braintree::Configuration
      delegate :custom_user_agent=, :environment=, :merchant_id=, :public_key=, :private_key=, :logger=, :to => Braintree::Configuration
      attr_accessor :mode, :require_postal_code, :require_street_address
    end

    self.custom_user_agent = "braintree-rails-#{Version}"
    self.mode = Mode::JS
    self.require_postal_code = true
    self.require_street_address = true
  end
end
