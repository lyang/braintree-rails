require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::FundingDetails do
  describe 'validations' do
    it "requries destination" do
      funding = BraintreeRails::FundingDetails.new(email_funding_details_hash.merge(:destination => nil))
      expect(funding).to be_invalid
      expect(funding.errors[:destination]).to eq(["can't be blank", "is not included in the list"])
    end

    it "cannot be trash destination" do
      funding = BraintreeRails::FundingDetails.new(email_funding_details_hash.merge(:destination => "foo"))
      expect(funding).to be_invalid
      expect(funding.errors[:destination]).to eq(["is not included in the list"])
    end

    it "requries email if destination is Email" do
      funding = BraintreeRails::FundingDetails.new(email_funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::Email, :email => nil))
      expect(funding).to be_invalid
      expect(funding.errors[:email]).to eq(["can't be blank"])
    end

    it "requries mobile_phone if destination is MobilePhone" do
      funding = BraintreeRails::FundingDetails.new(email_funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::MobilePhone, :mobile_phone => nil))
      expect(funding).to be_invalid
      expect(funding.errors[:mobile_phone]).to eq(["can't be blank"])
    end

    it "requries account_number and routing_number if destination is Bank" do
      funding = BraintreeRails::FundingDetails.new(email_funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::Bank, :account_number => nil, :routing_number => nil))
      expect(funding).to be_invalid
      expect(funding.errors[:account_number]).to eq(["can't be blank"])
      expect(funding.errors[:routing_number]).to eq(["can't be blank"])
    end
  end
end