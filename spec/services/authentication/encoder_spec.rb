require 'rails_helper'

RSpec.describe Authentication::Encoder, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:auth_encoder) { described_class.new(user:, jti_registry:) }

  context "when encoding a JWT, given a created user" do
    let(:user) { create(:user, id: 1) }
    let(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
    let(:expected_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }

    before do
      allow(Digest::UUID).to receive(:uuid_v4).and_return(jti_registry.jti)
    end

    it 'returns an instance of JwtAccessTokenCredentials' do
      expect(auth_encoder.call).to be_instance_of(Authentication::EncodedJwtAccessTokenCredentials)
    end

    it 'returns correct jti' do
      expect(auth_encoder.call.jti).to eq(jti_registry.jti)
    end

    it 'returns correct access token' do
      expect(auth_encoder.call.access_token).to eq(expected_access_token)
    end

    it 'returns correct exp' do
      expect(auth_encoder.call.exp).to eq(expected_exp)
    end
  end

  context 'when encoding a JWT, without a user' do
    let(:user) { nil }
    let(:jti_registry) { create(:jti_registry) }

    it 'raises an Authentication::Encoder::InvalidUserError' do
      expect { auth_encoder.call }.to raise_error(Errors::Authentication::Encoder::InvalidUser)
    end
  end

  context 'when encoding a JWT with invalid credentials' do
    let(:user) { nil }
    let(:jti_registry) { create(:jti_registry) }

    it 'raises an Authentication::Encoder::InvalidUserError' do
      expect { auth_encoder.call }.to raise_error(Errors::Authentication::Encoder::InvalidUser)
    end
  end
end
