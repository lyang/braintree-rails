require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Validator do
  describe "setup" do
    it "should be able to reset all callbacks" do
      begin
        customer = BraintreeRails::Customer.new(:id => '%')
        customer.valid?
        customer.errors[:id].wont_be :blank?

        BraintreeRails::CustomerValidator.setup {[]}
        customer.valid?.must_equal true
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
        customer.valid?.must_equal true
        customer.valid?(:create).must_equal false
        customer.save.must_equal false
        customer.errors[:id].wont_be :blank?
      ensure
        BraintreeRails::CustomerValidator.setup
      end
    end
  end
end
