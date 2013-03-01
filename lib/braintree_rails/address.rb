module BraintreeRails
  class Address < SimpleDelegator
    include Model
    define_attributes(
      :create => [:company, :country_code_numeric, :customer_id, :extended_address, :first_name, :id, :last_name, :locality, :postal_code, :region, :street_address],
      :update => [:company, :country_code_numeric, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address],
      :readonly => [:country_code_alpha2, :country_code_alpha3, :country_name, :created_at, :updated_at],
      :as_association => [:company, :country_code_alpha2, :country_code_alpha3, :country_code_numeric, :country_name, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address]
    )

    validates :first_name, :last_name, :company, :street_address, :extended_address, :locality, :region, :length => {:maximum => 255}
    validates :country_code_alpha2, :allow_blank => true, :inclusion => { :in => Braintree::Address::CountryNames.map {|country| country[1]} }
    validates :postal_code, :street_address, :presence => true
    validates :postal_code, :format => { :with => /\A[- a-z0-9]+\z/i}

    def self.find(customer_id, id)
      new(braintree_model_class.find(customer_id, id))
    end

    def self.delete(customer_id, id)
      braintree_model_class.delete(customer_id, id)
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def customer
      @customer ||= customer_id && Customer.new(customer_id)
    end

    [:country_name, :country_code_alpha2, :country_code_alpha3].each_with_index do |country, index|
      define_method("#{country}=") do |val|
        self.country_code_numeric = Braintree::Address::CountryNames.find{|country| country[index] == val}.try(:[], 3)
        self.instance_variable_set("@#{country}", val)
      end
    end

    def destroy
      if persisted?
        self.class.delete(customer_id, id)
      end
      self.persisted = false unless frozen?
      freeze
    end

    protected
    def update
      with_update_braintree do
        self.class.braintree_model_class.update(self.customer_id, self.id, attributes_for(:update))
      end
    end

    def update!
      with_update_braintree do
        self.class.braintree_model_class.update!(self.customer_id, self.id, attributes_for(:update))
      end
    end
  end
end
