module BraintreeRails
  class Customer < SimpleDelegator
    include Model

    define_attributes(
      :create => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website],
      :update => [:company, :custom_fields, :email, :fax, :first_name, :id, :last_name, :options, :phone, :website],
      :readonly => [:created_at, :updated_at],
      :as_association => [:id, :company, :email, :fax, :first_name, :last_name, :phone, :website]
    )

    validates :id, :format => {:with => /\A[-_a-z0-9]*\z/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}
    validates :first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def default_credit_card
      credit_cards.find(&:default?)
    end

    def addresses
      @addresses ||= Addresses.new(self)
    end

    def credit_cards
      @credit_cards ||= CreditCards.new(self)
    end

    def transactions
      @transactions ||= Transactions.new(self)
    end
  end
end
