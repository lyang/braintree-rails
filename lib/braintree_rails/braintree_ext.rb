[Braintree::Plan, Braintree::Modification].each do |model|
  model.class_eval do
   def self.find(id)
     all.find {|plan| plan.id == id}
   end
  end
end

module Braintree
  class Descriptor
    def ==(other)
      return false unless other.is_a?(Descriptor)
      name == other.name && phone == other.phone
    end
  end
end

module Braintree
  class Subscription
    def self.delete(id)
      cancel(id)
    end
  end
end

module Braintree
  class CreditCard
    def id
      token
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
