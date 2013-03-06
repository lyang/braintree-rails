module BraintreeRails
  class SubscriptionValidator < ActiveModel::Validator
    def setup(klass)
      klass.class_eval do
        validates :id, :format => {:with => /\A[-_[:alnum:]]*$\z/i},  :exclusion => {:in => %w(all new)}
        validates :billing_day_of_month, :numericality => { :only_integer => true }, :inclusion => {:in => [*(1..28), 31]}, :allow_nil => true
        validates :number_of_billing_cycles, :numericality => { :only_integer => true, :greater_than_or_equal_to  => 1 }, :allow_nil => true
        validates :payment_method_token, :presence => true, :if => :new_record?
        validates :plan_id, :presence => true, :if => :new_record?
        validates :price, :numericality => true, :allow_nil => true
        validates :trial_duration, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 9999 }, :if => :trial_period
        validates :trial_duration_unit, :presence => true, :inclusion => { :in => %w(day month) }, :if => :trial_period
      end
    end

    def validate(subscription)
      number_of_billing_cycles_must_be_greater_than_current_billing_cycle(subscription)
      first_billing_date_must_be_valid_future_date(subscription)
    end

    def number_of_billing_cycles_must_be_greater_than_current_billing_cycle(subscription)
      subscription.instance_eval do
        if number_of_billing_cycles.present? && current_billing_cycle.present?
          errors.add(:number_of_billing_cycles, "is too small.") if number_of_billing_cycles < current_billing_cycle
        end
      end
    end

    def first_billing_date_must_be_valid_future_date(subscription)
      subscription.instance_eval do
        begin
          if new_record? && first_billing_date.present?
            errors.add(:first_billing_date, "cannot be in the past.") if DateTime.parse(first_billing_date.to_s) < Date.today
          end
        rescue ArgumentError
          errors.add(:first_billing_date, "is invalid.")
        end
      end
    end
  end
end
