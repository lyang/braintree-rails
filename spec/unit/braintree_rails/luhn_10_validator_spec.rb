require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::Luhn10Validator do
  class Validatable < Struct.new(:number)
    include ActiveModel::Validations
    validates :number, 'braintree_rails/luhn_10' => true
  end

  describe 'valid numbers' do
    it 'should pass for valid numbers' do
      expect(Validatable.new(4111111111111111)).to be_valid
      expect(Validatable.new('5454545454545454')).to be_valid
    end
  end

  describe 'invalid numbers' do
    it 'should fail for invalid numbers' do
      invalid_record = Validatable.new('1234567890123456')
      expect(invalid_record).to_not be_valid
      expect(invalid_record.errors[:number]).to include 'failed Luhn 10 validation'
    end
  end
end
