module BraintreeRails
  class BusinessDetailsValidator < Validator
    Validations = [
      [:legal_name, :presence => true, :if => Proc.new {|business| business.tax_id.present?}],
      [:tax_id, :presence => true, :if => Proc.new {|business| business.legal_name.present?}],
    ]

    def validate(business)
      validate_association(business, :address)
    end
  end
end
