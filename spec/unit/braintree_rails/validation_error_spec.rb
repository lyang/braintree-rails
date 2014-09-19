require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::ApiError do
  describe "#to_s" do
    it "shows only the message" do
      expect(BraintreeRails::ApiError.new("error_message", "error code").to_s).to eq('error_message')
    end
  end

  describe "#inspect" do
    it "shows only the message" do
      expect(BraintreeRails::ApiError.new("error_message", "error code").inspect).to eq('#<BraintreeRails::ApiError (error code) error_message>')
    end
  end

  describe "#empty?" do
    it "delegate to message" do
      ["", "abc"].each do |message|
        expect(BraintreeRails::ApiError.new(message, "error code").empty?).to eq(message.empty?)
      end
    end
  end
end
