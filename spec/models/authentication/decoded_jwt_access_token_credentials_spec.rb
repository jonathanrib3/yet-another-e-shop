require 'rails_helper'

RSpec.describe Authentication::DecodedJwtAccessTokenCredentials, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:jti) }
    it { is_expected.to validate_presence_of(:iss) }

    it { is_expected.to validate_numericality_of(:exp).only_integer }
    it { is_expected.to validate_numericality_of(:iat).only_integer }
    it { is_expected.to validate_numericality_of(:sub).only_integer }
  end
end
