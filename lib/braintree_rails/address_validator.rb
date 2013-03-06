module BraintreeRails
  class AddressValidator < ActiveModel::Validator
    def setup(klass)
      klass.class_eval do
        validates :first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}
        validates :country_code_alpha2, :allow_blank => true, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[1]} }
        validates :postal_code, :street_address, :presence => true
        validates :postal_code, :format => { :with => /\A[- a-z0-9]+\z/i}
      end
    end

    def validate(address)
    end
  end
end
