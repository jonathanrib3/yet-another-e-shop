require 'rails_helper'

RSpec.describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:black_listed_tokens).dependent(:destroy) }
    it { is_expected.to have_one(:refresh_token).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to have_secure_password }
    it { is_expected.to define_enum_for(:role).with_values(%i[customer admin]) }

    context 'uniqueness' do
      let!(:user) { create(:user, email: 'somereallycoolemail@gov.com.br') }

      it { is_expected.to validate_uniqueness_of(:email) }
    end

    context 'when email format is valid' do
      let!(:user) { build(:user, email: 'somereallycoolemail@gov.com.br') }

      it('is valid') do
        expect(user).to be_valid
      end
    end

    context 'when email format is not valid' do
      context 'when starting it with a dot' do
        let!(:user) { build(:user, email: '.somereallycoolemail@gov.com.br') }

        it('is invalid') do
          expect(user).to be_invalid
        end
      end

      context 'when using a special char that is not ., - or _' do
        let!(:user) { build(:user, email: '.somereallycoolemail@gov.com.br') }

        it('is invalid') do
          expect(user).to be_invalid
        end
      end

      context 'when not containing only one @' do
        let!(:user) { build(:user, email: 'somereallycoolemail@g@ov.com.br') }

        it('is invalid') do
          expect(user).to be_invalid
        end
      end

      context 'when not having a valid domain name' do
        let!(:user) { build(:user, email: 'somereallycoolemail@123345.br') }
        let!(:user2) { build(:user, email: 'somereallycoolemail@g#v.com.br') }
        let!(:user3) { build(:user, email: 'somereallycoolemail@.com.br') }

        it('is invalid') do
          expect(user).to be_invalid
          expect(user2).to be_invalid
          expect(user3).to be_invalid
        end
      end
    end

    context 'when password has at least a lower letter, a upper letter, a digit and a special character' do
      let!(:user) { build(:user) }

      it 'is valid' do
        expect(user).to be_valid
      end
    end

    context 'when password doesnt have at least a lower letter' do
      let!(:user) { build(:user, password: '123A%') }

      it 'is invalid' do
        expect(user).to be_invalid
      end
    end

    context 'when password doesnt have at least a upper letter' do
      let!(:user) { build(:user, password: '123a%') }

      it 'is invalid' do
        expect(user).to be_invalid
      end
    end

    context 'when password doesnt have at least a digit' do
      let!(:user) { build(:user, password: 'aB%') }

      it 'is invalid' do
        expect(user).to be_invalid
      end
    end

    context 'when password doesnt have at least a special character' do
      let!(:user) { build(:user, password: '123aBB') }

      it 'is invalid' do
        expect(user).to be_invalid
      end
    end
  end

  context '#confirmed?' do
    context 'when user has confirmed_at' do
      let(:user) { build(:user, confirmed_at: Time.current) }

      it 'is returns true' do
        expect(user.confirmed?).to be true
      end
    end

    context 'when user has not confirmed_at' do
      let(:user) { build(:user, confirmed_at: nil) }

      it 'is returns false' do
        expect(user.confirmed?).to be false
      end
    end
  end
end
