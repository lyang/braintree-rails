module BraintreeRails
  class Customer < SimpleDelegator
    include Model

    define_attributes(
      :create => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website],
      :update => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website],
      :readonly => [:created_at, :updated_at],
      :as_association => [:id, :company, :email, :fax, :first_name, :last_name, :phone, :website]
    )

    define_associations(:addresses, :transactions, :credit_cards)

    validates_with CustomerValidator

    def ensure_model(model)
      if Braintree::Transaction::CustomerDetails === model
        super(model.id || extract_values(model))
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
