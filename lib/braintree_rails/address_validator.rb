module BraintreeRails
  class AddressValidator < ActiveModel::Validator
    def self.validate_postal_code?(address)
      true
    end

    def self.validate_street_address?(address)
      true
    end

    def setup(klass)
      klass.class_eval do
        validates :first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}
        validates :country_code_alpha2, :allow_blank => true, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[1]} }
        validates :street_address, :presence => true, :if => Proc.new { |address| AddressValidator.validate_street_address?(address) }
        validates :postal_code, :presence => true, :format => { :with => /\A[- a-z0-9]+\z/i}, :if => Proc.new { |address| AddressValidator.validate_postal_code?(address) }
      end
    end

    def validate(address)
    end
  end
end
