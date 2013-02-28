module BraintreeRails
  class Subscription < SimpleDelegator
    include Model

    define_attributes(
      :balance, :billing_day_of_month, :billing_period_end_date, :billing_period_start_date, :current_billing_cycle,
      :days_past_due, :failure_count, :first_billing_date, :id, :next_billing_date, :next_billing_period_amount, :number_of_billing_cycles,
      :options, :paid_through_date, :payment_method_token, :plan_id, :price, :status, :trial_duration, :trial_duration_unit, :trial_period
    )

    exclude_attributes_from(
      :create => [
        :balance, :billing_period_end_date, :billing_period_start_date, :current_billing_cycle, :days_past_due,
        :failure_count, :next_billing_date, :next_billing_period_amount, :paid_through_date, :status
      ],
      :update => [
        :balance, :billing_day_of_month, :billing_period_end_date, :billing_period_start_date, :current_billing_cycle,
        :days_past_due, :descriptor, :failure_count, :first_billing_date, :next_billing_date, :next_billing_period_amount, :number_of_billing_cycles,
        :paid_through_date, :status, :trial_duration, :trial_duration_unit, :trial_period
      ]
    )

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

    def plan
      @plan ||= plan_id && Plan.new(plan_id)
    end

    def credit_card
      @credit_card ||= payment_method_token && CreditCard.new(payment_method_token)
    end

    def add_ons
      @add_ons ||= AddOns.new(self)
    end

    def discounts
      @discounts ||= Discounts.new(self)
    end

    def transactions
      @transactions ||= Transactions.new(self)
    end
  end
end
