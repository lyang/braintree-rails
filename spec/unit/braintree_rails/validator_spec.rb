require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Validator do
  describe "setup" do
    it "should be able to reset all callbacks" do
      begin
        customer = BraintreeRails::Customer.new(:id => '%')
        customer.valid?
        customer.errors[:id].should_not be_blank

        BraintreeRails::CustomerValidator.setup {[]}
        customer.should be_valid
      ensure
        BraintreeRails::CustomerValidator.setup
      end
    end

    it "should be able to add additional validations" do
      begin
        BraintreeRails::CustomerValidator.setup do |validations|
          [[:id, :length => {:is => 3}, :on => :create]]
        end

        customer = BraintreeRails::Customer.new(:id => '%')
        customer.should be_valid
        customer.valid?(:create).should be_false
        customer.save.should be_false
        customer.errors[:id].should_not be_blank
      ensure
        BraintreeRails::CustomerValidator.setup
      end
    end
  end
end
