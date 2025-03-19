require 'rails_helper'

RSpec.describe Authentication::Refresher, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:auth_refresher) { described_class.new(refresh_token:) }

  context "when refreshing an access token with a valid refresh token" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_new_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:refresh_token) do
      "56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b"
    end
    let(:crypted_refresh_token) do
      Digest::SHA256.hexdigest(refresh_token + 'secret')
    end
    let(:user) { create(:user, id: 1) }
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }
    let(:expiry_hours) { 12 }
    let(:jwt_encoder_credentials) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        access_token: expected_new_access_token,
        jti: expected_jti,
        exp: expected_exp
      )
    end
    let(:refresh_token_expiry_days) { 30 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS', refresh_token_expiry_days)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Authentication::Encoder).to receive(:new).and_return(jwt_encoder_service)
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
      travel_to(fixed_time)
      create(:refresh_token, crypted_token: crypted_refresh_token, jti: expected_jti, user:)
    end

    it 'returns an instance of EncodedJwtAccessAndRefreshTokenCredentials' do
      expect(auth_refresher.call).to be_instance_of(Authentication::EncodedJwtAccessAndRefreshTokenCredentials)
    end

    it 'returns the used refresh token' do
      expect(auth_refresher.call.refresh_token).to eq(refresh_token)
    end

    it 'returns a new access token' do
      expect(auth_refresher.call.access_token).to eq(expected_new_access_token)
    end
  end

  context "when refreshing an access token with an expired refresh token" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:refresh_token) do
      "56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b"
    end
    let(:crypted_refresh_token) do
      Digest::SHA256.hexdigest(refresh_token + 'secret')
    end
    let(:user) { create(:user, id: 1) }
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }
    let(:expiry_hours) { 12 }
    let(:refresh_token_expiry_days) { 30 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS', refresh_token_expiry_days)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
      travel_to(fixed_time)
      create(:refresh_token, crypted_token: crypted_refresh_token, exp: 12.minutes.ago, user:, jti:)
    end

    it 'raises an Authentication::Refresher::RefreshTokenExpired error' do
      expect { auth_refresher.call }.to raise_error(Errors::Authentication::Refresher::RefreshTokenExpired)
    end
  end

  context 'when refreshing an access token with a refresh token that doesnt exist' do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:refresh_token) do
      "56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b"
    end
    let(:expiry_hours) { 12 }
    let(:refresh_token_expiry_days) { 30 }
    let(:expected_error) { "Couldn't find RefreshToken with [WHERE \"refresh_tokens\".\"crypted_token\" = $1]" }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS', refresh_token_expiry_days)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')

      travel_to(fixed_time)
    end

    it 'raises an ActiveRecord::RecordNotFound error' do
      expect { auth_refresher.call }.to raise_error(ActiveRecord::RecordNotFound, expected_error)
    end
  end

  context 'when refreshing an access token with a blank refresh token' do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:refresh_token) { nil }
    let(:expiry_hours) { 12 }
    let(:refresh_token_expiry_days) { 30 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS', refresh_token_expiry_days)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      travel_to(fixed_time)
    end

    it 'raises an Authentication::Refresher::RefreshTokenNotFound error' do
      expect { auth_refresher.call }.to raise_error(Errors::Authentication::Refresher::RefreshTokenNotFound)
    end
  end
end
