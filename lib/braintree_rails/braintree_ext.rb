[Braintree::Plan, Braintree::Modification].each do |model|
  model.class_eval do
   def self.find(id)
     all.find {|model| model.id == id}
   end
  end
end

module Braintree
  class Descriptor
    def ==(other)
      return false unless other.is_a?(Descriptor)
      name == other.name && phone == other.phone
    end

    def attributes_for(action)
      {:name => name, :phone => phone}
    end
  end
end

module Braintree
  class Subscription
    def self.delete(id)
      cancel(id)
    end

    def never_expires
      @never_expires
    end
  end
end

module Braintree
  class CreditCard
    def id
      token
    end

    def expired
      @expired
    end

    def default
      @default
    end

    def number
      nil
    end

    def cvv
      nil
    end
  end
end

module Braintree
  class Transaction
    class CreditCardDetails
      def id
        token
      end
    end
  end
end

module Braintree
  class MerchantAccount
    alias_method :individual, :individual_details
    alias_method :business, :business_details
    alias_method :funding, :funding_details

    class IndividualDetails
      attr_reader :id
      alias_method :address, :address_details
    end

    class BusinessDetails
      attr_reader :id
      alias_method :address, :address_details
    end

    class FundingDetails
      attr_reader :id
    end

    class AddressDetails
      attr_reader :id
    end
  end
end
