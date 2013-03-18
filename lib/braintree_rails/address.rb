module BraintreeRails
  class Address
    include Model
    define_attributes(
      :create => [:company, :country_code_numeric, :customer_id, :extended_address, :first_name, :id, :last_name, :locality, :postal_code, :region, :street_address],
      :update => [:company, :country_code_numeric, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address],
      :readonly => [:country_code_alpha2, :country_code_alpha3, :country_name, :created_at, :updated_at],
      :as_association => [:company, :country_code_numeric, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address]
    )

    define_associations(:customer => :customer_id)

    def self.auto_set_country_code_numeric(country_attribute, index)
      define_method("#{country_attribute}=") do |val|
        self.country_code_numeric = Braintree::Address::CountryNames.find{|country_name| country_name[index] == val}.try(:[], 3)
        self.instance_variable_set("@#{country_attribute}", val)
      end
    end

    def self.find(customer_id, id)
      new(braintree_model_class.find(customer_id, id))
    end

    def self.delete(customer_id, id)
      braintree_model_class.delete(customer_id, id)
    end

    def ensure_model(model)
      if Braintree::Transaction::AddressDetails === model
        assign_attributes(extract_values(model))
        self.persisted = model.id.present?
        model
      else
        super
      end
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def destroy
      if persisted?
        run_callbacks :destroy do
          self.class.delete(customer_id, id)
        end
      end
      self.persisted = false unless frozen?
      freeze
    end

    protected
    def update
      with_update_braintree(:update) do
        self.class.braintree_model_class.update(self.customer_id, self.id, attributes_for(:update))
      end
    end

    def update!
      with_update_braintree(:update) do
        self.class.braintree_model_class.update!(self.customer_id, self.id, attributes_for(:update))
      end
    end

    [:country_name, :country_code_alpha2, :country_code_alpha3].each_with_index do |country_attribute, index|
      auto_set_country_code_numeric(country_attribute, index)
    end
  end
end
