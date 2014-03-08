require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'MerchantAccount Integration' do
  it 'should fetch merchant account from Braintree for given id' do
    braintree_merchant_account = Braintree::MerchantAccount.find(BraintreeRails::Configuration.default_merchant_account_id)
    merchant_account = BraintreeRails::MerchantAccount.new(BraintreeRails::Configuration.default_merchant_account_id)
    merchant_account.id.should == braintree_merchant_account.id
    merchant_account.status.should == braintree_merchant_account.status
  end

  it 'can create sub merchant account' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash)
    merchant_account.should be_persisted
  end

  it 'sets validation errors properly to its associations' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => {}, :funding => {}, :business => {:legal_name => "foo"}))
    merchant_account.should_not be_persisted
    merchant_account.individual.errors.should_not be_empty
    merchant_account.funding.errors.should_not be_empty
    merchant_account.business.errors.should_not be_empty
  end

  it 'can update the submerchant account' do
    individual = merchant_account_hash[:individual].merge(:first_name => "foo")
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => individual))
    merchant_account.should be_persisted
    merchant_account.individual.first_name.should == "foo"
    merchant_account.update_attributes(:individual => {:first_name => "bar"})
    merchant_account.individual.first_name.should == "bar"
  end
end
