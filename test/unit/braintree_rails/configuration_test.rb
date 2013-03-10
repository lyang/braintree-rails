require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Configuration do
  [:merchant_id, :public_key, :private_key, :logger].each do |config|
    it "should delegate #{config} to Braintree::Configuration.#{config}" do
      begin
        old_value = Braintree::Configuration.send(config)
        BraintreeRails::Configuration.send("#{config}=", "foo")
        Braintree::Configuration.send(config).must_equal "foo"
        BraintreeRails::Configuration.send(config).must_equal "foo"
      ensure
        BraintreeRails::Configuration.send("#{config}=", old_value)
      end
    end
  end

  it "should delegate environment to Braintree::Configuration" do
    BraintreeRails::Configuration.environment = :sandbox
    Braintree::Configuration.environment.must_equal :sandbox
    BraintreeRails::Configuration.environment.must_equal :sandbox
  end

  it "should set custom_user_agent to braintree-rails-#{BraintreeRails::Version}" do
    Braintree::Configuration.instantiate.user_agent.must_include "braintree-rails-#{BraintreeRails::Version}"
  end
end
