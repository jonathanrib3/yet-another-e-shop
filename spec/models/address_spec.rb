require 'rails_helper'

RSpec.describe Address, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:line_1) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to define_enum_for(:address_type) }

    context "residential address uniqueness" do
      context "when there is only one residential address by customer" do
        let(:address) { create(:address) }

        it "is valid" do
          expect(address).to be_valid
        end
      end

      context "when there are more than one residential address by customer" do
        let(:customer) { create(:customer) }
        let(:address) { build(:address, customer:) }

        before do
          create(:address, customer:)
        end

        it "is invalid" do
          expect(address).to be_invalid
        end

        it "adds an error to the model" do
          address.validate
          expect(address.errors.to_a).to eq([ "Customer #{I18n.t("errors.address.attributes.user_id.duplicate_residential_address")}" ])
        end
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:customer) }
  end
end
