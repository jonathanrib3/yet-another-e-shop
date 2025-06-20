require 'rails_helper'

RSpec.describe Authentication::Login, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:login) { described_class.new(email:, password:) }

  context "when logging in with valid email and password" do
    let!(:user) { create(:user, id: 1) }
    let(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
    let(:exp) { fixed_time.advance(hours: expiry_hours) }
    let(:iss) { jwt_issuer }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:refresh_token) { "574b49a8987bdedfe6e7bedc64f3da5d161eef1ec99dd1d334a4034fb8d3fbe6" }
    let(:encoded_token) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        jti: jti_registry.jti,
        access_token:,
        exp:
      )
    end
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: encoded_token) }
    let(:email) { user.email }
    let(:password) { "123123Qwe." }

    before do
      allow(Tokens).to receive(:generate_random_token).and_return(refresh_token)
      allow(Digest::UUID).to receive(:uuid_v4).and_return(jti_registry.jti)
    end

    it 'returns an instance of Authentication::EncodedJwtAccessAndRefreshTokenCredential' do
      expect(login.call).to be_instance_of(Authentication::EncodedJwtAccessAndRefreshTokenCredentials)
    end

    it 'returns a new access token' do
      expect(login.call.access_token).to eq(access_token)
    end

    it 'creates a new refresh token' do
      expect { login.call }.to change(RefreshToken.where(jti: jti_registry.jti), :count).by(1)
    end

    it 'returns a new refresh token' do
      expect(login.call.refresh_token).to eq(refresh_token)
    end
  end

  context "when logging in with invalid email" do
    let!(:user) { create(:user, id: 1) }
    let(:email) { "user.email@mail.com" }
    let(:password) { "123123Qwe." }

    it 'raises an Authentication::Login::InvalidEmailOrPassword error' do
      expect { login.call }.to raise_error(Errors::Authentication::Login::InvalidEmailOrPassword)
    end
  end

  context "when logging in with invalid password" do
    let!(:user) { create(:user, id: 1) }
    let(:email) { user.email }
    let(:password) { "invalid password" }

    it 'raises an Authentication::Login::InvalidEmailOrPassword error' do
      expect { login.call }.to raise_error(Errors::Authentication::Login::InvalidEmailOrPassword)
    end
  end
end
