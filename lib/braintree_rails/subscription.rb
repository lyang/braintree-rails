module BraintreeRails
  class Subscription < SimpleDelegator
    include Model

    define_attributes(
      :create => [
        :billing_day_of_month, :first_billing_date, :id, :merchant_account_id, :never_expires, :number_of_billing_cycles,
        :payment_method_token, :plan_id, :price, :trial_duration, :trial_duration_unit, :trial_period, :options, :descriptor
      ],
      :update => [
        :id, :merchant_account_id, :never_expires, :number_of_billing_cycles,
        :payment_method_token, :plan_id, :price, :options
      ],
      :readonly => [
        :balance, :billing_period_end_date, :billing_period_start_date, :current_billing_cycle, :days_past_due,
        :failure_count, :next_billing_date, :next_billing_period_amount, :paid_through_date, :status
      ]
    )

    define_associations(:add_ons, :discounts, :transactions, :plan => :plan_id, :credit_card => :payment_method_token)

    validates :id, :format => {:with => /\A[-_[:alnum:]]*$\z/i},  :exclusion => {:in => %w(all new)}
    validates :billing_day_of_month, :numericality => { :only_integer => true }, :inclusion => {:in => [*(1..28), 31]}, :allow_nil => true
    validates :number_of_billing_cycles, :numericality => { :only_integer => true, :greater_than_or_equal_to  => 1 }, :allow_nil => true
    validates :payment_method_token, :presence => true, :if => :new_record?
    validates :plan_id, :presence => true, :if => :new_record?
    validates :price, :numericality => true, :allow_nil => true
    validates :trial_duration, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 9999 }, :if => :trial_period
    validates :trial_duration_unit, :presence => true, :inclusion => { :in => %w(day month) }, :if => :trial_period

    validates_each :number_of_billing_cycles, :if => Proc.new {|subscription| subscription.current_billing_cycle.present? } do |record, attribute, value|
      record.errors.add(attribute, "is too small.") if value.present? && value < record.current_billing_cycle
    end

    validates_each :first_billing_date, :allow_nil => true, :if => :new_record? do |record, attribute, value|
      begin
        date = DateTime.parse(value.to_s)
        record.errors.add(attribute, "cannot be in the past.") if date < Date.today
      rescue ArgumentError
        record.errors.add(attribute, "is invalid.")
      end
    end

    def price=(val)
      @price = val.blank? ? nil : val
    end
  end
end
