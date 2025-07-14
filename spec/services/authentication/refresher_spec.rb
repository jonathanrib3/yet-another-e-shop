require 'rails_helper'

RSpec.describe Authentication::Refresher, type: :service do
  include_context 'current time and authentication constants stubs'

  subject(:auth_refresher) { described_class.new(refresh_token:) }

  context 'when refreshing an access token with a valid refresh token' do
    let(:expected_exp) { fixed_time.advance(hours: expiry_hours).to_i }
    let(:user) { create(:user, id: 1) }
    let(:refresh_token_jti_registry) { create(:jti_registry, jti: '8eafd5e2-85b4-4432-8f39-0f5de61001fa', user:) }
    let(:new_access_token_jti) { 'c9a59b52-6257-4c87-a577-a489bd1ece98' }
    let(:expected_new_access_token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM' \
      '5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRl' \
      'c3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g'
    end
    let(:refresh_token) do
      '56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b'
    end

    let(:crypted_refresh_token) do
      Digest::SHA256.hexdigest("#{refresh_token}secret")
    end
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }
    let(:jwt_encoder_credentials) do
      Authentication::EncodedJwtAccessTokenCredentials.new(
        access_token: expected_new_access_token,
        jti: new_access_token_jti,
        exp: expected_exp
      )
    end

    before do
      allow(Authentication::Encoder).to receive(:new).and_return(jwt_encoder_service)
      allow(Digest::UUID).to receive(:uuid_v4).and_return(new_access_token_jti)

      create(:refresh_token, crypted_token: crypted_refresh_token, jti_registry: refresh_token_jti_registry)
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

  context 'when refreshing an access token with an expired refresh token' do
    let(:exp) { fixed_time.advance(hours: expiry_hours).to_i }
    let(:jti) { '8eafd5e2-85b4-4432-8f39-0f5de61001fa' }
    let(:refresh_token) do
      '56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b'
    end
    let(:refresh_token_jti_registry) { create(:jti_registry, jti: '8eafd5e2-85b4-4432-8f39-0f5de61001fa', user:) }
    let(:crypted_refresh_token) do
      Digest::SHA256.hexdigest("#{refresh_token}secret")
    end
    let(:user) { create(:user, id: 1) }
    let(:jwt_encoder_service) { instance_double(Authentication::Encoder, call: jwt_encoder_credentials) }

    before do
      allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)

      create(:refresh_token, crypted_token: crypted_refresh_token, exp: 12.minutes.ago,
                             jti_registry: refresh_token_jti_registry)
    end

    it 'raises an Authentication::InvalidRefreshToken error' do
      expect { auth_refresher.call }.to raise_error(Errors::Authentication::InvalidRefreshToken)
    end
  end

  context 'when refreshing an access token with a refresh token that doesnt exist' do
    let(:refresh_token) do
      '56e7eb8f326fbe336aa768a8ed3c298d06c027f48ce4439c9d484146f4d59e2b'
    end

    it 'raises an Authentication::InvalidRefreshToken error' do
      expect { auth_refresher.call }.to raise_error(Errors::Authentication::InvalidRefreshToken)
    end
  end
end
