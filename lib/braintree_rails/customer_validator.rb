module BraintreeRails
  class CustomerValidator < ActiveModel::Validator
    def setup(klass)
      klass.class_eval do
        validates :id, :format => {:with => /\A[-_a-z0-9]*\z/i}, :length => {:maximum => 36}, :exclusion => {:in => %w(all new)}
        validates :first_name, :last_name, :company, :website, :phone, :fax, :length => {:maximum => 255}
      end
    end

    def validate(customer)
    end
  end
end
