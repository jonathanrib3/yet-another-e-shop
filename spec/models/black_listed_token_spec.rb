require 'rails_helper'

RSpec.describe BlackListedToken, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:jti) }
    it { is_expected.to validate_presence_of(:exp) }

    context 'uniqueness' do
      let!(:black_listed_token) { create(:black_listed_token) }

      it { is_expected.to validate_uniqueness_of(:user_id) }
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end
end
