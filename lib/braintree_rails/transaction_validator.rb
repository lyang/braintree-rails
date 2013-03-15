module BraintreeRails
  class TransactionValidator < Validator
    Validations = [
      [:amount, :presence => true, :numericality => {:greater_than_or_equal_to => 0}, :if => :new_record?],
      [:type, :presence => true, :inclusion => {:in => %w(sale credit)}, :if => :new_record?],
      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Authorized]}, :on => :submit_for_settlement],
      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Settled, Braintree::Transaction::Status::Settling]}, :on => :refund],
      [:status, :inclusion => {:in => [Braintree::Transaction::Status::Authorized, Braintree::Transaction::Status::SubmittedForSettlement]}, :on => :void]
    ]

    def setup(*)
      self.class.model_class.class_eval do
        define_model_callbacks :submit_for_settlement, :refund, :void
      end
      super
    end

    def validate(transaction)
      must_have_credit_card(transaction) if transaction.new_record?
    end

    def must_have_credit_card(transaction)
      if transaction.credit_card.blank?
        validate_customer_have_default_credit_card(transaction)
      elsif transaction.credit_card.new_record?
        validate_new_credit_card(transaction)
      end
    end

    def validate_customer_have_default_credit_card(transaction)
      if transaction.customer.blank?
        transaction.errors.add(:base, "Either customer or credit card is required.")
      elsif transaction.customer.default_credit_card.blank?
        transaction.errors.add(:base, "does not have a default credit card.")
      end
    end

    def validate_new_credit_card(transaction)
      transaction.credit_card.billing_address = transaction.billing
      if transaction.credit_card.invalid?
        transaction.credit_card.errors.full_messages.each do |message|
          transaction.errors.add(:base, message)
        end
      end
    end
  end
end
