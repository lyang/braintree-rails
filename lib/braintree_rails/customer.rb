module BraintreeRails
  class Customer < SimpleDelegator
    include Model
    define_attributes(:company, :created_at, :custom_fields, :email, :fax, :first_name, :id, :last_name, :phone, :updated_at, :website)

    exclude_attributes_from(
      :create => [:created_at, :updated_at],
      :update => [:id, :created_at, :updated_at],
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
