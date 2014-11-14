require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Configuration do
  [:merchant_id, :public_key, :private_key, :logger].each do |config|
    it "should delegate #{config} to Braintree::Configuration.#{config}" do
      begin
        old_value = Braintree::Configuration.send(config)
        BraintreeRails::Configuration.send("#{config}=", "foo")
        expect(Braintree::Configuration.send(config)).to eq("foo")
        expect(BraintreeRails::Configuration.send(config)).to eq("foo")
      ensure
        BraintreeRails::Configuration.send("#{config}=", old_value)
      end
    end
  end

  it "should delegate environment to Braintree::Configuration" do
    BraintreeRails::Configuration.environment = :sandbox
    expect(Braintree::Configuration.environment).to eq(:sandbox)
    expect(BraintreeRails::Configuration.environment).to eq(:sandbox)
  end

  it "should set custom_user_agent to braintree-rails-#{BraintreeRails::Version}" do
    expect(Braintree::Configuration.instantiate.user_agent).to include "braintree-rails-#{BraintreeRails::Version}"
  end
end