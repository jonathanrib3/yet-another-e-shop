require 'rails_helper'

RSpec.describe Address, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:line_1) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to define_enum_for(:address_type) }
  end

  context "associations" do
    it { is_expected.to belong_to(:customer) }
  end
end
