require 'rails_helper'

RSpec.describe Authentication::Issuer, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:auth_issuer) { described_class.new(user:) }

  context "when issuing jwt credentials, given an user" do
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:expected_refresh_token) do
      "56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b"
    end
    let(:expected_crypted_refresh_token) do
      Digest::SHA256.hexdigest(expected_refresh_token + 'secret')
    end
    let(:user) { create(:user, id: 1) }
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }
    let(:jwt_encoder_credentials) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        access_token: expected_access_token,
        jti: expected_jti,
        exp: expected_exp
      )
    end

    before do
      allow(Authentication::Encoder).to receive(:new).and_return(jwt_encoder_service)
      allow(Tokens).to receive(:generate_random_token).and_return(expected_refresh_token)
    end

    it 'returns an instance of EncodedJwtAccessAndRefreshTokenCredentials' do
      expect(auth_issuer.call).to be_instance_of(Authentication::EncodedJwtAccessAndRefreshTokenCredentials)
    end

    it 'creates a new refresh token' do
      expect { auth_issuer.call }.to change(RefreshToken.where(crypted_token: expected_crypted_refresh_token), :count).by(1)
    end

    it 'returns correct access token' do
      expect(auth_issuer.call.access_token).to eq(expected_access_token)
    end

    it 'returns refresh token' do
      expect(auth_issuer.call.refresh_token).to eq(expected_refresh_token)
    end
  end

  context "when issuing jwt credentials, given an user, being that a refresh token has already been issued" do
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:expected_jti) { "b98d42ac-6539-40f3-86e8-abc4e64d442a" }
    let(:expected_access_token) do
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsImp0aSI6ImI5OGQ0MmFjLTY1MzktNDBmMy04NmU4LWFiYzRlNjRkNDQyYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.0Ywk9VKEZPzChfs81OrBwftCFUWGXJgwDRIauVacGzw"
    end
    let(:expected_refresh_token) do
      "b0b25a091157beba0305d7f2e4310eb8c134ce441c9462edeb4e857f59412c1a"
    end
    let(:expected_crypted_refresh_token) do
      Digest::SHA256.hexdigest(expected_refresh_token + 'secret')
    end
    let(:user) { create(:user, id: 1) }
    let!(:previous_refresh_token) do
      create(:refresh_token, user:, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa")
    end
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }
    let(:jwt_encoder_credentials) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        access_token: expected_access_token,
        jti: expected_jti,
        exp: expected_exp
      )
    end

    before do
      allow(Authentication::Encoder).to receive(:new).and_return(jwt_encoder_service)
      allow(Tokens).to receive(:generate_random_token).and_return(expected_refresh_token)
    end

    it 'returns an instance of EncodedJwtAccessAndRefreshTokenCredentials' do
      expect(auth_issuer.call).to be_instance_of(Authentication::EncodedJwtAccessAndRefreshTokenCredentials)
    end

    it 'creates a new refresh token' do
      expect { auth_issuer.call }.to change(RefreshToken.where(crypted_token: expected_crypted_refresh_token), :count).by(1)
    end

    it 'deletes the previous refresh token associated to the user' do
      expect { auth_issuer.call }.to change(RefreshToken.where({ jti: previous_refresh_token.jti }), :count).from(1).to(0)
    end

    it 'returns correct access token' do
      expect(auth_issuer.call.access_token).to eq(expected_access_token)
    end

    it 'returns refresh token' do
      expect(auth_issuer.call.refresh_token).to eq(expected_refresh_token)
    end
  end

  context "when issuing jwt credentials, without an user" do
    let(:user) { nil }

    it 'raises an Authentication::Issuer::InvalidUser error' do
      expect { auth_issuer }.to raise_error(Errors::Authentication::Issuer::InvalidUser)
    end
  end
end
