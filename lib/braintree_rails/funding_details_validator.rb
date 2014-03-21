module BraintreeRails
  class FundingDetailsValidator < Validator
    Validations = [
      [:destination, :presence => true, :inclusion => {:in => [Braintree::MerchantAccount::FundingDestination::Bank, Braintree::MerchantAccount::FundingDestination::Email, Braintree::MerchantAccount::FundingDestination::MobilePhone]}],
      [:email, :presence => true, :if => Proc.new {|business| business.destination == Braintree::MerchantAccount::FundingDestination::Email}],
      [:mobile_phone, :presence => true, :if => Proc.new {|business| business.destination == Braintree::MerchantAccount::FundingDestination::MobilePhone}],
      [:account_number, :routing_number, :presence => true, :if => Proc.new {|business| business.destination == Braintree::MerchantAccount::FundingDestination::Bank}],
    ]
  end
end
