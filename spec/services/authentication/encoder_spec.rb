require 'rails_helper'

RSpec.describe Authentication::Encoder, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:auth_encoder) { described_class.new(user:) }

  context "when encoding a JWT, given a created user" do
    let(:user) { create(:user, id: 1) }
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:expiry_hours) { 12 }
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
      travel_to(fixed_time)
    end

    it 'returns an instance of JwtAccessTokenCredentials' do
      expect(auth_encoder.call).to be_instance_of(Authentication::EncodedJwtAccessTokenCredentials)
    end

    it 'returns correct jti' do
      expect(auth_encoder.call.jti).to eq(expected_jti)
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

    it 'raises an Authentication::Encoder::InvalidUserError' do
      expect { auth_encoder.call }.to raise_error(Errors::Authentication::Encoder::InvalidUser)
    end
  end
end
