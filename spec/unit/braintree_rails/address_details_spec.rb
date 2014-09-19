require File.expand_path(File.join(File.dirname(__FILE__), '../unit_spec_helper'))

describe BraintreeRails::AddressDetails do
  describe 'validations' do
    [:street_address, :locality, :region, :postal_code].each do |attribute|
      it "requires #{attribute}" do
        address = BraintreeRails::AddressDetails.new(address_details_hash.merge(attribute => nil))
        expect(address).to be_invalid
        expect(address.errors[attribute]).to eq(["can't be blank"])
      end
    end
  end
end
