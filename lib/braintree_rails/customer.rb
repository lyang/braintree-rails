module BraintreeRails
  class Customer
    include Model

    define_attributes(
      :create => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website, :credit_card, :device_data],
      :update => [:company, :custom_fields, :email, :fax, :first_name, :last_name, :options, :phone, :website, :credit_card, :device_data],
      :readonly => [:created_at, :updated_at],
      :as_association => [:id, :company, :email, :fax, :first_name, :last_name, :phone, :website]
    )

    has_many :addresses,    :class => Addresses
    has_many :transactions, :class => Transactions
    has_many :credit_cards, :class => CreditCards
    has_one  :credit_card,  :class => CreditCard

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

    def add_errors(validation_errors)
      credit_card.add_errors(validation_errors.except(:base)) if credit_card
      super(validation_errors)
    end

    def attributes_for(action)
      super.merge(credit_card_attributes(action))
    end

    def default_credit_card
      credit_cards.find(&:default?)
    end

    def credit_card_attributes(action)
      credit_card.present? ? {:credit_card => credit_card.attributes_for(action).except(:customer_id, :token)} : {}
    end
  end
end
