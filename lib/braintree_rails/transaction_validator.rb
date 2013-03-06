module BraintreeRails
  class TransactionValidator < ActiveModel::Validator
    def setup(klass)
      klass.class_eval do
        validates :amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
        validates :type, :presence => true, :inclusion => {:in => %w(sale credit)}
      end
    end

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
