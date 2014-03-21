module BraintreeRails
  class MerchantAccountValidator < Validator
    Validations = [
      [:id, :format => {:with => /\A[-_a-z0-9]*\z/i}, :length => {:maximum => 32}, :exclusion => {:in => %w(all new)}],
      [:tos_accepted, :master_merchant_account_id, :individual, :funding, :presence => true],
    ]

    def validate(merchant_account)
      [:individual, :business, :funding].each do |association_name|
        validate_association(merchant_account, association_name)
      end
    end
  end
end
