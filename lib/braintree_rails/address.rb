module BraintreeRails
  class Address < SimpleDelegator
    Attributes = [:id, :customer_id, :first_name, :last_name, :company, :street_address, :extended_address, :locality, :country_name, :country_code_alpha2, :country_code_alpha3, :country_code_numeric, :region, :postal_code]
    include Model

    validates :first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}
    validates :country_code_alpha2, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[1]} }
    validates :postal_code, :street_address, :presence => true
    validates :postal_code, :format => { :with => /^[- a-z0-9]+$/i}

    def initialize(address = {})
      address = ensure_address(address)
      assign_attributes(extract_values(address))
      super
    end

    def country_name=(val)
      self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[0] == val}.try(:[], 1)
      @country_name = val
    end

    def country_code_alpha3=(val)
      self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[2] == val}.try(:[], 1)
      @country_code_alpha3 = val
    end

    def country_code_numeric=(val)
      self.country_code_alpha2= Braintree::Address::CountryNames.find{|country| country[3] == val}.try(:[], 1)
      @country_code_numeric = val
    end

    def destroy!
      if persisted?
        self.class.braintree_model_class.delete(customer_id, id)
      end
      @persisted = false
      freeze
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

    def update
      with_update_braintree do
        self.class.braintree_model_class.update(self.customer_id, self.id, self.attributes.except(:id, :customer_id))
      end
    end

    def update!
      with_update_braintree do
        self.class.braintree_model_class.update!(self.customer_id, self.id, self.attributes.except(:id, :customer_id))
      end
    end

    def attributes_to_exclude_from_update
      [:id, :customer_id, :country_name, :country_code_alpha3, :country_code_numeric]
    end

    def attributes_to_exclude_from_create
      [:country_name, :country_code_alpha3, :country_code_numeric]
    end
  end
end