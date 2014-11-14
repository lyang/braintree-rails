require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::BusinessDetails do
  describe 'validations' do
    it "requries legal_name if tax_id is present" do
      business = BraintreeRails::BusinessDetails.new(business_details_hash.merge(:legal_name => nil))
      expect(business).to be_invalid
      expect(business.errors[:legal_name]).to eq(["can't be blank"])
    end

    it "requries tax_id if legal_name is present" do
      business = BraintreeRails::BusinessDetails.new(business_details_hash.merge(:tax_id => nil))
      expect(business).to be_invalid
      expect(business.errors[:tax_id]).to eq(["can't be blank"])
    end

    it "does not requrie either if neither are present" do
      business = BraintreeRails::BusinessDetails.new({})
      expect(business).to be_valid
    end

    it "validates assocaited address" do
      business = BraintreeRails::BusinessDetails.new(address_details_hash.merge(:address => {}))
      expect(business).to be_invalid
      expect(business.errors[:address]).to_not be_empty
    end
  end
end