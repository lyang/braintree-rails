module BraintreeRails
  class Customer < SimpleDelegator
    include Model

    define_attributes(
      :create => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website],
      :update => [:company, :custom_fields, :email, :fax, :first_name, :last_name, :options, :phone, :website],
      :readonly => [:created_at, :updated_at],
      :as_association => [:id, :company, :email, :fax, :first_name, :last_name, :phone, :website]
    )

    define_associations(:addresses, :transactions, :credit_cards)

    def ensure_model(model)
      if Braintree::Transaction::CustomerDetails === model
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

    def default_credit_card
      credit_cards.find(&:default?)
    end
  end
end
