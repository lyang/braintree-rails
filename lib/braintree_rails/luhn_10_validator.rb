module BraintreeRails
  class Luhn10Validator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless record.errors[attribute].blank?
      record.errors.add(attribute, 'failed Luhn 10 validation.') if invalid_luhn_10_number?(value)
    end

    private
    def invalid_luhn_10_number?(number)
      number.to_s.split('').reverse.each_slice(2).sum{|odd, even| [odd, even.to_i*2].join.split('').sum(&:to_i) } % 10 != 0
    end
  end
end
