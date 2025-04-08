require 'rails_helper'

RSpec.describe JtiRegistry, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:refresh_token).dependent(:destroy) }
    it { is_expected.to have_one(:black_listed_token).dependent(:destroy) }
  end
end
