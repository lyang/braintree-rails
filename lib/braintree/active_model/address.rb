module Braintree
  module ActiveModel
    class Address < SimpleDelegator
      Attributes = [:id, :customer_id, :first_name, :last_name, :company, :street_address, :extended_address, :locality, :country_code_alpha2, :region, :postal_code]
      include BraintreeModel

      validates :first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}
      validates :country_code_alpha2, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[1]} }
      validates :postal_code, :street_address, :presence => true
      validates :postal_code, :format => { :with => /^[- a-z0-9]+$/i}

      def self.attributes
        [:id, :customer_id, :first_name, :last_name, :company, :street_address, :extended_address, :locality, :country_code_alpha2, :region, :postal_code]
      end

      def initialize(address = {})
        address = ensure_address(address)
        write_attributes(extract_values(address))
        super
      end

      def country_name=(val)
        self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[0] == val}[1]
      end

      def country_code_alpha3=(val)
        self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[2] == val}[1]
      end

      def country_code_numeric=(val)
        self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[3] == val}[1]
      end

      protected
      def ensure_address(address)
        case address
        when Braintree::Address
          @persisted = true
          address
        when Hash
          @persisted = false
          OpenStruct.new(address)
        else
          @persisted = address.respond_to?(:persisted?) ? address.persisted? : false
          address
        end
      end
    end
  end
end