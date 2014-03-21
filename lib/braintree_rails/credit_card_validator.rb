module BraintreeRails
  class CreditCardValidator < Validator
    Validations = [
      [:cardholder_name, :length => {:maximum => 255}],
      [:customer_id, :presence => true, :length => {:maximum => 36}, :on => :create],
      [:number, :presence => true, :allow_blank => false, :if => :new_record?],
      [:number, :numericality => {:only_integer => true}, :length => {:minimum => 12, :maximum => 19}, 'braintree_rails/luhn_10' => true, :if => Proc.new { Configuration.mode == Configuration::Mode::S2S }],
      [:cvv, :presence => true, :allow_blank => false, :if => :new_record?],
      [:cvv, :numericality => {:only_integer => true}, :length => {:minimum => 3, :maximum => 4}, :if => Proc.new { Configuration.mode == Configuration::Mode::S2S }],
      [:expiration_month, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_date.blank? }],
      [:expiration_year, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_date.blank? }],
      [:expiration_date, :presence => true, :if => Proc.new { |credit_card| credit_card.new_record? && credit_card.expiration_month.blank? }],
      [:expiration_month, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }, :if => Proc.new { Configuration.mode == Configuration::Mode::S2S }],
      [:expiration_year, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1976, :less_than_or_equal_to => 2200 }, :if => Proc.new { Configuration.mode == Configuration::Mode::S2S }],
      [:billing_address, :presence => true, :if => Proc.new {Configuration.require_postal_code || Configuration.require_street_address}],
    ]

    def validate(credit_card)
      validate_association(credit_card, :billing_address)
    end
  end
end
