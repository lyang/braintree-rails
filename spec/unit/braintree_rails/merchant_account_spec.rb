require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::MerchantAccount do
  describe 'validations' do
    [:tos_accepted, :master_merchant_account_id, :individual, :funding].each do |attribute|
      it "requires #{attribute}" do
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(attribute => nil))
        merchant_account.should be_invalid
        merchant_account.errors[attribute].should == ["can't be blank"]
      end
    end

    it "validates id format" do
      [nil, "", "a", "_", "-", "0", "a"*32].each do |valid_value|
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => valid_value))
        merchant_account.should be_valid
      end

      ["%", "/"].each do |invalid_value|
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => invalid_value))
        merchant_account.should be_invalid
        merchant_account.errors[:id].should == ["is invalid"]
      end
    end

    it "validates id length" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => "a"*33))
      merchant_account.should be_invalid
      merchant_account.errors[:id].should == ["is too long (maximum is 32 characters)"]
    end

    it "validates individual" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:individual => {}))
      merchant_account.should be_invalid
      merchant_account.errors[:individual].should_not be_empty
    end

    it "validates funding" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:funding => {}))
      merchant_account.should be_invalid
      merchant_account.errors[:funding].should_not be_empty
    end

    it "validates business if present" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:business => {:legal_name => "foo"}))
      merchant_account.should be_invalid
      merchant_account.errors[:business].should_not be_empty
    end
  end
end
