module BraintreeRails
  class CreditCard < SimpleDelegator
    Attributes = [:customer_id, :number, :token, :cvv, :cardholder_name, :expiration_month, :expiration_year, :billing_address].freeze
    
    include Model

    validates :customer_id, :presence => true, :length => {:maximum => 36}, :if => :new_record?
    validates :number, :presence => true, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, :if => :new_record?
    validates :cvv, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 9999 }
    validates :cardholder_name, :length => {:maximum => 255}
    validates :expiration_month, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
    validates :expiration_year,  :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }
    validates_each :billing_address do |record, attribute, value|
      record.errors.add(attribute, "is not valid. #{value.errors.full_messages.join("\n")}") unless value.try(:valid?)
    end

    def initialize(credit_card = {})
      credit_card = ensure_credit_card(credit_card)
      assign_attributes(extract_values(credit_card))
      super
    end

    def id
      token
    end

    def expiration_date=(date)
      expiration_month, expiration_year = date.split('/')
      self.expiration_month = expiration_month
      self.expiration_year = expiration_year.gsub(/^(\d\d)$/, '20\1')
    end

    def billing_address=(val)
      @billing_address = val.is_a?(Address) ? val : Address.new(val)
    end

    protected
    def ensure_credit_card(credit_card)
      case credit_card
      when String
        @persisted = true
        Braintree::CreditCard.find(credit_card)
      when Braintree::CreditCard
        @persisted = true
        credit_card
      when Hash
        @persisted = false
        OpenStruct.new(credit_card.reverse_merge(:billing_address => {}))
      else
        @persisted = credit_card.respond_to?(:persisted?) ? credit_card.persisted? : false
        credit_card
      end
    end
  end
end