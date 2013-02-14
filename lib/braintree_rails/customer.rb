module BraintreeRails
  class Customer < SimpleDelegator
    include Model
    define_attributes(:id, :first_name, :last_name, :email, :company, :website, :phone, :fax, :created_at, :updated_at)

    validates :id, :format => {:with => /^[-_a-z0-9]*$/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}
    validates :first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}

    attr_reader :addresses, :credit_cards

    def initialize(customer = {})
      customer = ensure_model(customer)
      set_addresses(customer)
      set_credit_cards(customer)
      super(customer)
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def transactions
      new_record? ? [] : @transactions ||= Transactions.new(self)
    end

    private
    def set_addresses(customer)
      addresses = customer.respond_to?(:addresses) ? customer.addresses : []
      @addresses = Addresses.new(self, addresses)
    end

    def set_credit_cards(customer)
      credit_cards = customer.respond_to?(:credit_cards) ? customer.credit_cards : []
      @credit_cards = CreditCards.new(self, credit_cards)
    end
  end
end
