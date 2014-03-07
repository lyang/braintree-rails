require File.expand_path(File.join(File.dirname(__FILE__), '../integration_test_helper'))

describe 'MerchantAccount Integration' do
  it 'should fetch merchant account from Braintree for given id' do
    braintree_merchant_account = Braintree::MerchantAccount.find(BraintreeRails::Configuration.default_merchant_account_id)
    merchant_account = BraintreeRails::MerchantAccount.new(BraintreeRails::Configuration.default_merchant_account_id)
    merchant_account.id.must_equal braintree_merchant_account.id
    merchant_account.status.must_equal braintree_merchant_account.status
  end

  it 'can create sub merchant account' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash)
    merchant_account.must_be :persisted?
  end

  it 'sets validation errors properly to its associations' do
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => {}, :funding => {}, :business => {:legal_name => "foo"}))
    merchant_account.wont_be :persisted?
    merchant_account.individual.errors.wont_be :empty?
    merchant_account.funding.errors.wont_be :empty?
    merchant_account.business.errors.wont_be :empty?
  end

  it 'can update the submerchant account' do
    individual = merchant_account_hash[:individual].merge(:first_name => "foo")
    merchant_account = BraintreeRails::MerchantAccount.create(merchant_account_hash.merge(:individual => individual))
    merchant_account.must_be :persisted?
    merchant_account.individual.first_name.must_equal "foo"
    merchant_account.update_attributes(:individual => {:first_name => "bar"})
    merchant_account.individual.first_name.must_equal "bar"
  end
end
