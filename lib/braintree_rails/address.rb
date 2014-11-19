module BraintreeRails
  class Address
    include Model
    define_attributes(
      :create => [:company, :country_name, :customer_id, :extended_address, :first_name, :id, :last_name, :locality, :postal_code, :region, :street_address],
      :update => [:company, :country_name, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address],
      :readonly => [:country_code_alpha2, :country_code_alpha3, :country_code_numeric, :created_at, :updated_at],
      :as_association => [:company, :country_name, :extended_address, :first_name, :last_name, :locality, :postal_code, :region, :street_address]
    )

    belongs_to :customer, :class_name => "BraintreeRails::Customer", :foreign_key => :customer_id

    CountryNames = {
      :country_name => 0,
      :country_code_alpha2 => 1,
      :country_code_alpha3 => 2,
      :country_code_numeric => 3
    }

    def self.sync_country_name_attributes(country_attribute, index)
      define_method("#{country_attribute}=") do |value|
        CountryNames.except(country_attribute).each do |other_attribute, other_index|
          other_value = Braintree::Address::CountryNames.find{|country_name| country_name[index] == value}.try(:[], other_index)
          instance_variable_set("@#{other_attribute}", other_value)
        end
        instance_variable_set("@#{country_attribute}", value)
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

    CountryNames.each do |attribute, index|
      sync_country_name_attributes(attribute, index)
    end
  end
end