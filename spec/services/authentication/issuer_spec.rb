require 'rails_helper'

RSpec.describe Authentication::Issuer, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:auth_issuer) { described_class.new(user:) }

  context "when issuing jwt credentials, given an user" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
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
    let(:expiry_hours) { 12 }
    let(:jwt_encoder_credentials) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        access_token: expected_access_token,
        jti: expected_jti,
        exp: expected_exp
      )
    end

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Authentication::Encoder).to receive(:new).and_return(jwt_encoder_service)
      allow(Tokens).to receive(:generate_random_token).and_return(expected_refresh_token)
      travel_to(fixed_time)
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

  context "when issuing jwt credentials, without an user" do
    let(:user) { nil }
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:expiry_hours) { 12 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      travel_to(fixed_time)
    end

    it 'raises an Authentication::Issuer::InvalidUser error' do
      expect { auth_issuer }.to raise_error(Errors::Authentication::Issuer::InvalidUser)
    end
  end
end
