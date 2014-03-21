module BraintreeRails
  class BusinessDetailsValidator < Validator
    Validations = [
      [:legal_name, :presence => true, :if => Proc.new {|business| business.tax_id.present?}],
      [:tax_id, :presence => true, :if => Proc.new {|business| business.legal_name.present?}],
    ]

    def validate(business)
      validate_address(business) if business.address.present?
    end

    def validate_address(business)
      business.instance_eval do
        if address.invalid?
          errors.add(:address, "is invalid")
          address.errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end
      end
    end
  end
end
