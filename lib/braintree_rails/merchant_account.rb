module BraintreeRails
  class MerchantAccount
    include Model

    # Need to remove the ! methods as those are not provided by the API
    singleton_class.not_supported_apis(:delete, :create!, :update!)
    not_supported_apis(:destroy, :create!, :update!)

    define_attributes(
      :create => [:tos_accepted, :master_merchant_account_id, :id, :individual, :business, :funding],
      :readonly => [:status, :created_at, :updated_at]
    )

    belongs_to :master_merchant_account, :class_name => "BraintreeRails::MerchantAccount"
    has_one :individual, :class_name => "BraintreeRails::IndividualDetails"
    has_one :business, :class_name => "BraintreeRails::BusinessDetails"
    has_one :funding, :class_name => "BraintreeRails::FundingDetails"

    # Need to reload to populate association values as there's an inconsistency in the API
    after_create :reload, :if => :persisted?

    def add_errors(validation_errors)
      propagate_errors_to_associations(extract_errors(validation_errors))
      super(validation_errors)
    end

    def propagate_errors_to_associations(validation_errors)
      [individual, business, funding].each do |association|
        association.add_errors(validation_errors) if association && errors
      end
    end

    def attributes_for(action)
      super.merge(individual_attributes).merge(business_attributes).merge(funding_attributes)
    end

    def individual_attributes
      individual.present? ? {:individual => individual.attributes_for(:as_association)} : {}
    end

    def business_attributes
      business.present? ? {:business => business.attributes_for(:as_association)} : {}
    end

    def funding_attributes
      funding.present? ? {:funding => funding.attributes_for(:as_association)} : {}
    end
  end
end
