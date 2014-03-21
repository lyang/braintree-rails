require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::FundingDetails do
  describe 'validations' do
    it "requries destination" do
      funding = BraintreeRails::FundingDetails.new(funding_details_hash.merge(:destination => nil))
      funding.should be_invalid
      funding.errors[:destination].should == ["can't be blank", "is not included in the list"]
    end

    it "cannot be trash destination" do
      funding = BraintreeRails::FundingDetails.new(funding_details_hash.merge(:destination => "foo"))
      funding.should be_invalid
      funding.errors[:destination].should == ["is not included in the list"]
    end

    it "requries email if destination is Email" do
      funding = BraintreeRails::FundingDetails.new(funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::Email, :email => nil))
      funding.should be_invalid
      funding.errors[:email].should == ["can't be blank"]
    end

    it "requries mobile_phone if destination is MobilePhone" do
      funding = BraintreeRails::FundingDetails.new(funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::MobilePhone, :mobile_phone => nil))
      funding.should be_invalid
      funding.errors[:mobile_phone].should == ["can't be blank"]
    end

    it "requries account_number and routing_number if destination is Bank" do
      funding = BraintreeRails::FundingDetails.new(funding_details_hash.merge(:destination => Braintree::MerchantAccount::FundingDestination::Bank, :account_number => nil, :routing_number => nil))
      funding.should be_invalid
      funding.errors[:account_number].should == ["can't be blank"]
      funding.errors[:routing_number].should == ["can't be blank"]
    end
  end
end
