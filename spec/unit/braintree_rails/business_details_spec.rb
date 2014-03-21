require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::BusinessDetails do
  describe 'validations' do
    it "requries legal_name if tax_id is present" do
      business = BraintreeRails::BusinessDetails.new(business_details_hash.merge(:legal_name => nil))
      business.should be_invalid
      business.errors[:legal_name].should == ["can't be blank"]
    end

    it "requries tax_id if legal_name is present" do
      business = BraintreeRails::BusinessDetails.new(business_details_hash.merge(:tax_id => nil))
      business.should be_invalid
      business.errors[:tax_id].should == ["can't be blank"]
    end

    it "does not requrie either if neither are present" do
      business = BraintreeRails::BusinessDetails.new({})
      business.should be_valid
    end

    it "validates assocaited address" do
      business = BraintreeRails::BusinessDetails.new(address_details_hash.merge(:address => {}))
      business.should be_invalid
      business.errors[:address].should_not be_empty
    end
  end
end
