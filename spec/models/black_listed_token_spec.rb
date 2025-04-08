require 'rails_helper'

RSpec.describe BlackListedToken, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:jti) }
    it { is_expected.to validate_presence_of(:exp) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:jti_registry).with_foreign_key(:jti).with_primary_key(:jti) }
  end
end
