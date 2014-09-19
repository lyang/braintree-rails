require File.expand_path(File.join(File.dirname(__FILE__), '../integration_spec_helper'))

describe 'MerchantAccount Integration' do
  it 'should fetch merchant account from Braintree for given id' do
    braintree_merchant_account = Braintree::MerchantAccount.find(BraintreeRails::Configuration.default_merchant_account_id)
    merchant_account = BraintreeRails::MerchantAccount.new(BraintreeRails::Configuration.default_merchant_account_id)
    expect(merchant_account.id).to eq(braintree_merchant_account.id)
    expect(merchant_account.status).to eq(braintree_merchant_account.status)
  end

  it 'can create sub merchant account' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash)
    expect(merchant_account).to be_persisted
  end

  it 'does not consider merchant account persisted if rejected by Braintree' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:tos_accepted => 'false'))
    expect(merchant_account).to_not be_persisted
  end

  it 'sets validation errors properly to its associations' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => {}, :funding => {}, :business => {:legal_name => "foo"}))
    expect(merchant_account).to_not be_persisted
    expect(merchant_account.individual.errors).to_not be_empty
    expect(merchant_account.funding.errors).to_not be_empty
    expect(merchant_account.business.errors).to_not be_empty
  end

  it 'can update the submerchant account' do
    individual = merchant_account_hash[:individual].merge(:first_name => "foo")
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => individual))
    expect(merchant_account).to be_persisted
    expect(merchant_account.individual.first_name).to eq("foo")
    merchant_account.update_attributes(:individual => {:first_name => "bar"})
    expect(merchant_account.individual.first_name).to eq("bar")
  end
end
