require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::IndividualDetails do
  describe 'validations' do
    [:first_name, :last_name, :email, :date_of_birth, :address].each do |attribute|
      it "requires #{attribute}" do
        individual = BraintreeRails::IndividualDetails.new(individual_details_hash.merge(attribute => nil))
        individual.should be_invalid
        individual.errors[attribute].should == ["can't be blank"]
      end
    end

    it "validates assocaited address" do
      individual = BraintreeRails::IndividualDetails.new(individual_details_hash.merge(:address => {}))
      individual.should be_invalid
      individual.errors[:address].should_not be_empty
    end
  end
end
