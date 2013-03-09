module BraintreeRails
  class TransactionValidator < Validator
    Validations = [
      [:amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}],
      [:type, :presence => true, :inclusion => {:in => %w(sale credit)}]
    ]

    def validate(transaction)
      must_have_credit_card(transaction)
    end

    def must_have_credit_card(transaction)
      transaction.instance_eval do
        errors.add(:base, "Either customer or credit card is required.") and return if customer.blank? && credit_card.blank?
        errors.add(:customer, "does not have a default credit card.") if credit_card.blank? && customer.default_credit_card.blank?
      end
    end
  end
end
