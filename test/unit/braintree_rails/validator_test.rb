require File.expand_path(File.join(File.dirname(__FILE__), '../unit_test_helper'))

describe BraintreeRails::Validator do
  describe "setup" do
    it "should be able to reset all callbacks" do
      begin
        default_validations = BraintreeRails::CustomerValidator::Validations
        customer = BraintreeRails::Customer.new(:id => '%')
        customer.valid?
        customer.errors[:id].wont_be :blank?
        BraintreeRails::CustomerValidator::Validations.clear
        BraintreeRails::CustomerValidator.setup
        customer.valid?.must_equal true
      ensure
        BraintreeRails::CustomerValidator::Validations.push(*default_validations)
      end
    end

    it "should be able to add additional validations" do
      begin
        default_validations = BraintreeRails::CustomerValidator::Validations
        BraintreeRails::CustomerValidator::Validations.clear
        validation_on_create = [:id, :length => {:is => 3}, :on => :create]
        BraintreeRails::CustomerValidator::Validations.push(validation_on_create)
        BraintreeRails::CustomerValidator.setup

        customer = BraintreeRails::Customer.new(:id => '%')
        customer.valid?.must_equal true
        customer.valid?(:create).must_equal false
        customer.save.must_equal false
        customer.errors[:id].wont_be :blank?
      ensure
        BraintreeRails::CustomerValidator::Validations.push(*default_validations)
      end
    end
  end
end
