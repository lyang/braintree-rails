require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::MerchantAccount do
  describe 'validations' do
    [:tos_accepted, :master_merchant_account_id, :individual, :funding].each do |attribute|
      it "requires #{attribute}" do
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(attribute => nil))
        expect(merchant_account).to be_invalid
        expect(merchant_account.errors[attribute]).to eq(["can't be blank"])
      end
    end

    it "validates id format" do
      [nil, "", "a", "_", "-", "0", "a"*32].each do |valid_value|
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => valid_value))
        expect(merchant_account).to be_valid
      end

      ["%", "/"].each do |invalid_value|
        merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => invalid_value))
        expect(merchant_account).to be_invalid
        expect(merchant_account.errors[:id]).to eq(["is invalid"])
      end
    end

    it "validates id length" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:id => "a"*33))
      expect(merchant_account).to be_invalid
      expect(merchant_account.errors[:id]).to eq(["is too long (maximum is 32 characters)"])
    end

    it "validates individual" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:individual => {}))
      expect(merchant_account).to be_invalid
      expect(merchant_account.errors[:individual]).to_not be_empty
    end

    it "validates funding" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:funding => {}))
      expect(merchant_account).to be_invalid
      expect(merchant_account.errors[:funding]).to_not be_empty
    end

    it "validates business if present" do
      merchant_account = BraintreeRails::MerchantAccount.new(merchant_account_hash.merge(:business => {:legal_name => "foo"}))
      expect(merchant_account).to be_invalid
      expect(merchant_account.errors[:business]).to_not be_empty
    end
  end
end
