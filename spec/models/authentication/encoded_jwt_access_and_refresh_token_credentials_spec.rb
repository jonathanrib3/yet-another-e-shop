require 'rails_helper'

RSpec.describe Authentication::EncodedJwtAccessAndRefreshTokenCredentials, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:refresh_token) }
    it { is_expected.to validate_presence_of(:access_token) }
  end
end
