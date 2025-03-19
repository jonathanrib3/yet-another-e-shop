require 'rails_helper'

RSpec.describe Authentication::Decoder, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:auth_decoder) { described_class.new(access_token:) }

  context "when decoding a valid access token" do
    let!(:user) { create(:user, id: 1) }
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_exp) { Time.now().advance(hours: Authentication::Constants::EXPIRY_TIME_IN_HOURS).to_i }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', 12)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
      travel_to(fixed_time)
    end

    it 'returns an instance of DecodedJwtAccessTokenCredentials' do
      expect(auth_decoder.call).to be_instance_of(Authentication::DecodedJwtAccessTokenCredentials)
    end

    it 'returns correct sub, containing the user id of the token owner' do
      expect(auth_decoder.call.sub).to eq(user.id)
    end

    it 'returns correct jti' do
      expect(auth_decoder.call.jti).to eq(expected_jti)
    end

    it 'returns correct exp' do
      expect(auth_decoder.call.exp).to eq(expected_exp)
    end

    it 'returns correct iat' do
      expect(auth_decoder.call.iat).to eq(fixed_time.to_i)
    end
  end

  context 'when decoding a blank access token' do
    let(:access_token) { nil }

    it 'raises an Authentication::Decoder::BlankAccessToken' do
      expect { auth_decoder.call }.to raise_error(Errors::Authentication::Decoder::BlankAccessToken)
    end
  end

  context "when decoding an access token that contains an id from a user that doesn't exist" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_exp) { Time.now().advance(hours: Authentication::Constants::EXPIRY_TIME_IN_HOURS).to_i }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', 12)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
      travel_to(fixed_time)
    end

    it 'raises an Authentication::Decoder::UserNotFound' do
      expect { auth_decoder.call }.to raise_error(Errors::Authentication::Decoder::UserNotFound)
    end
  end
end
