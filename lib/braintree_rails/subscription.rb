module BraintreeRails
  class Subscription
    include Model

    define_attributes(
      :create => [
        :billing_day_of_month, :first_billing_date, :id, :merchant_account_id, :never_expires, :number_of_billing_cycles,
        :payment_method_token, :plan_id, :price, :trial_duration, :trial_duration_unit, :trial_period, :options, :descriptor
      ],
      :update => [
        :merchant_account_id, :never_expires, :number_of_billing_cycles,
        :payment_method_token, :plan_id, :price, :options
      ],
      :readonly => [
        :balance, :billing_period_end_date, :billing_period_start_date, :current_billing_cycle, :days_past_due,
        :failure_count, :next_billing_date, :next_billing_period_amount, :paid_through_date, :status
      ]
    )

    has_many   :add_ons,      :class_name => "BraintreeRails::AddOns"
    has_many   :discounts,    :class_name => "BraintreeRails::Discounts"
    has_many   :transactions, :class_name => "BraintreeRails::Transactions"
    belongs_to :plan,         :class_name => "BraintreeRails::Plan",            :foreign_key => :plan_id
    belongs_to :credit_card,  :class_name => "BraintreeRails::CreditCard",      :foreign_key => :payment_method_token

    def self.cancel(id)
      delete(id)
    end

    def cancel
      destroy
    end

    def price=(val)
      @price = val.blank? ? nil : val
    end

    def never_expires?
      never_expires
    end
  end
end
