require 'rails_helper'

RSpec.describe Authentication::Authenticator, type: :service do
  include_context 'current time and authentication constants stubs'

  subject(:authenticator) { described_class.new(access_token:) }

  context 'when authenticating a valid token' do
    let!(:user) { create(:user, id: 1) }
    let(:jti) { '8eafd5e2-85b4-4432-8f39-0f5de61001fa' }
    let(:exp) { fixed_time.advance(hours: expiry_hours) }
    let(:iss) { 'localhost.test' }
    let(:access_token) do
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM' \
      '5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRl' \
      'c3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g'
    end
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        iat: fixed_time,
        exp:,
        jti:,
        iss:
      )
    end
    let(:jwt_decoder_service) { instance_double(Authentication::Decoder, call: decoded_token) }

    before do
      allow(Authentication::Decoder).to receive(:new).and_return(jwt_decoder_service)
      allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
    end

    it 'returns the user corresponding to the token sub' do
      expect(authenticator.call).to eq(user)
    end
  end

  context 'when authenticating an invalid token' do
    context 'when user does not exists' do
      let!(:user) { create(:user, id: 1) }
      let(:jti) { '8eafd5e2-85b4-4432-8f39-0f5de61001fa' }
      let(:iss) { jwt_issuer }
      let(:exp) { fixed_time.advance(hours: expiry_hours).to_i }
      let(:access_token) do
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjE5ODQsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04' \
        'ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0' \
        'LnRlc3QifQ.bwLymbjXzbALShUWSxDEZDHQhQnl0zqUlzrxm0dfCIQ'
      end
      let(:decoded_token) do
        Authentication::DecodedJwtAccessTokenCredentials.new(
          sub: 1984,
          iat: fixed_time,
          exp:,
          jti:,
          iss:
        )
      end
      let(:jwt_decoder_service) { instance_double(Authentication::Decoder, call: decoded_token) }

      before do
        allow(Authentication::Decoder).to receive(:new).and_return(jwt_decoder_service)
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
      end

      it 'raises an Authentication::InvalidAccessToken error' do
        expect { authenticator.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
      end
    end

    context 'when token is blacklisted' do
      let!(:user) { create(:user, id: 1) }
      let(:jti_registry) { create(:jti_registry, jti: '8eafd5e2-85b4-4432-8f39-0f5de61001fa', user:) }
      let(:exp) { fixed_time.advance(hours: expiry_hours) }
      let(:iss) { jwt_issuer }
      let(:access_token) do
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM' \
        '5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRl' \
        'c3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g'
      end
      let!(:blacklisted_token) do
        create(:black_listed_token, jti_registry:, exp:)
      end
      let(:decoded_token) do
        Authentication::DecodedJwtAccessTokenCredentials.new(
          sub: user.id,
          iat: fixed_time,
          jti: jti_registry.jti,
          exp:,
          iss:
        )
      end
      let(:jwt_decoder_service) { instance_double(Authentication::Decoder, call: decoded_token) }

      before do
        allow(Authentication::Decoder).to receive(:new).and_return(jwt_decoder_service)
      end

      it 'raises an Authentication::InvalidAccessToken error' do
        expect { authenticator.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
      end
    end

    context 'when token is not authentic' do
      let!(:user) { create(:user, id: 1) }
      let(:jti) { '8eafd5e2-85b4-4432-8f39-0f5de61001fa' }
      let(:exp) { fixed_time.advance(hours: expiry_hours).to_i }
      let(:invalid_iss) { 'any_other_invalid_issuer' }
      let(:valid_iss) { jwt_issuer }
      let(:access_token) do
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM' \
        '5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoiaW52YWxpZF9pc3N1' \
        'ZXIifQ.VpG8OGIu-M0OCi0kJe649v37DxRSMsxKsCgjlHVEg2s'
      end
      let(:decoded_token) do
        Authentication::DecodedJwtAccessTokenCredentials.new(
          sub: 1984,
          iat: fixed_time,
          iss: invalid_iss,
          exp:,
          jti:
        )
      end
      let(:jwt_decoder_service) { instance_double(Authentication::Decoder, call: decoded_token) }

      before do
        allow(Authentication::Decoder).to receive(:new).and_return(jwt_decoder_service)
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
      end

      it 'raises an Authentication::InvalidAccessToken error' do
        expect { authenticator.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
      end
    end
  end
end
