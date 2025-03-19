require 'rails_helper'

RSpec.describe Authentication::Decoder, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:auth_decoder) { described_class.new(access_token:) }

  context "when decoding a valid access token" do
    let!(:user) { create(:user, id: 1) }
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end

    before do
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
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

    it 'raises an Errors::Authentication::InvalidAccessToken error' do
      expect { auth_decoder.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end

  context "when decoding an access token that contains an id from a user that doesn't exist" do
    let(:expected_jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:expected_exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end

    before do
      allow(Digest::UUID).to receive(:uuid_v4).and_return(expected_jti)
    end

    it 'raises an Errors::Authentication::InvalidAccessToken' do
      expect { auth_decoder.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end
end
