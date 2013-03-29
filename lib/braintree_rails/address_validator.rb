module BraintreeRails
  class AddressValidator < Validator
    Validations = [
      [:customer_id, :presence => true, :length => {:maximum => 36}, :on => :create],
      [:first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}],
      [:country_name, :allow_blank => true, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[0]}, :message => "%{value} is not allowed" }],
      [:street_address, :presence => true, :if => Proc.new { Configuration.require_street_address }],
      [:postal_code, :presence => true, :format => { :with => /\A[- a-z0-9]+\z/i}, :if => Proc.new { |address| address.errors[:postal_code].blank? && Configuration.require_postal_code }]
    ]
  end
end
