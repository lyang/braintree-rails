require 'delegate'
module Braintree
  module ActiveModel
    class CreditCard < SimpleDelegator
      Attributes = [:customer_id, :number, :token, :cvv, :cardholder_name, :expiration_month, :expiration_year, :billing_address].freeze
      
      include BraintreeModel

      validates :customer_id, :presence => true, :length => {:maximum => 36}, :if => :new_record?
      validates :number, :presence => true, :numericality => { :only_integer => true }, :length => {:minimum => 12, :maximum => 19}, :if => :new_record?
      validates :cvv, :presence => true, :numericality => { :only_integer => true }, :length => {:minimum => 3, :maximum => 4}
      validates :cardholder_name, :presence => true, :length => {:maximum => 255}
      validates :expiration_month, :presence => true, :inclusion => { :in => ('1'..'12').to_a + (1..12).to_a }
      validates :expiration_year,  :presence => true, :inclusion => { :in => ('1976'..'2200').to_a + (1976..2200).to_a }
      validates_each :billing_address do |record, attribute, value|
        record.errors.add(attribute, "is not valid. #{value.errors.full_messages.join("\n")}") unless value.try(:valid?)
      end

      def initialize(credit_card = {})
        credit_card = ensure_credit_card(credit_card)
        write_attributes(extract_values(credit_card))
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
end