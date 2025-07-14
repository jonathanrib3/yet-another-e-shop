require 'rails_helper'

RSpec.describe Users::Create, type: :service do
  subject(:create_new_user_service) { described_class.new(email:, password:, role:) }
  context 'when creating a new user with valid data' do
    let(:password) { '123123Qwe.' }
    let(:email) { 'john.doe@example.com' }
    let(:role) { :admin }

    it 'creates a new, UNCONFIRMED user with said data' do
      expect { create_new_user_service.call }.to change(User.where({ email:, confirmed_at: nil }), :count).from(0).to(1)
    end

    it 'returns the created user' do
      expect(create_new_user_service.call).to be_instance_of(User)
    end
  end

  context 'when creating a new user with blank password or email' do
    let(:password) { nil }
    let(:email) { nil }
    let(:role) { :admin }
    let(:expected_errors) do
      I18n.t 'errors.services.create_user.invalid_attributes'
    end

    it 'raises a Users::CreateUser::InvalidAttributes with a message' do
      expect do
        create_new_user_service.call
      end.to raise_error(Errors::Users::CreateUser::InvalidAttributes, expected_errors)
    end
  end

  context 'when creating a new user with invalid password and email' do
    let(:password) { '1231' }
    let(:email) { '.johndoe@123.com' }
    let(:role) { :admin }
    let(:expected_errors) do
      "Validation failed: Email #{I18n.t 'errors.attributes.email.invalid'}," \
      " Password #{I18n.t 'errors.attributes.password.invalid'}"
    end

    it 'returns an ActiveRecord::RecordInvalid error with a message' do
      expect { create_new_user_service.call }.to raise_error(ActiveRecord::RecordInvalid, expected_errors)
    end
  end

  context 'when creating a new user with invalid role' do
    let(:password) { '1231aB#' }
    let(:email) { 'john.doe@example.com' }
    let(:role) { :invalid_role }
    let(:expected_errors) do
      "Validation failed: Role #{I18n.t('errors.messages.inclusion')}"
    end

    it 'returns an ActiveRecord::RecordInvalid error with a message' do
      expect { create_new_user_service.call }.to raise_error(ActiveRecord::RecordInvalid, expected_errors)
    end
  end
end
