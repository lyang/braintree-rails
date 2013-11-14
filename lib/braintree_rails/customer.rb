module BraintreeRails
  class Customer
    include Model

    define_attributes(
      :create => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website, :credit_card],
      :update => [:company, :custom_fields, :email, :fax, :first_name, :last_name, :options, :phone, :website, :credit_card],
      :readonly => [:created_at, :updated_at],
      :as_association => [:id, :company, :email, :fax, :first_name, :last_name, :phone, :website]
    )

    has_many :addresses,    :class => Addresses
    has_many :transactions, :class => Transactions
    has_many :credit_cards, :class => CreditCards

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
