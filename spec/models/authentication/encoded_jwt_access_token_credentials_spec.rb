require 'rails_helper'

RSpec.describe Authentication::EncodedJwtAccessTokenCredentials, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:jti) }
    it { is_expected.to validate_presence_of(:access_token) }
    it { is_expected.to validate_numericality_of(:exp).only_integer }
  end
end
