module BraintreeRails
  class Luhn10Validator < ActiveModel::Validator
    def validate(record)
      record.errors.add(attribute, 'must be an integer') unless valid_integer?(value(record))
      record.errors.add(attribute, message) unless valid_luhn_10_number?(value(record))
    end

    private
    def valid_integer?(number)
      number =~ /\A\d+\z/
    end

    def valid_luhn_10_number?(number)
      number.split('').reverse.each_slice(2).sum{|odd, even| [odd, even.to_i*2].join.split('').sum(&:to_i) } % 10 == 0
    end

    def attribute
      options[:attribute]
    end

    def value(record)
      record.send(attribute).to_s
    end

    def message
      options[:message] || "failed Luhn 10 validation."
    end
  end
end
