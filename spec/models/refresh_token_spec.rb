require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:crypted_token) }
    it { is_expected.to validate_presence_of(:exp) }

    context 'uniqueness' do
      let!(:refresh_token) { create(:refresh_token) }

      it { is_expected.to validate_uniqueness_of(:user_id) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
