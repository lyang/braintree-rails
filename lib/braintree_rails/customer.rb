module BraintreeRails
  class Customer < SimpleDelegator
    Attributes = [:id, :first_name, :last_name, :email, :company, :website, :phone, :fax, :created_at, :updated_at].freeze
    include Model

    validates :id, :format => {:with => /^[-_a-z0-9]*$/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}
    validates :first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}

    attr_reader :addresses, :credit_cards
    
    def initialize(customer = {})
      customer = ensure_customer(customer)
      assign_attributes(extract_values(customer))
      @addresses = Addresses.new(self, customer.addresses)
      @credit_cards = CreditCards.new(self, customer.credit_cards)
      super
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def transactions
      new_record? ? [] : @transactions ||= Transactions.new(self)
    end

    protected
    def ensure_customer(customer)
      case customer
      when String
        @persisted = true
        Braintree::Customer.find(customer)
      when Braintree::Customer
        @persisted = true
        customer
      when Hash
        @persisted = false
        OpenStruct.new(customer.reverse_merge(:addresses => [], :credit_cards => []))
      else
        @persisted = customer.respond_to?(:persisted?) ? customer.persisted? : false
        customer
      end
    end
  end
end