require 'rails_helper'

RSpec.describe Authentication::Revoker, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:auth_revoker) { described_class.new(decoded_token:, user:) }

  context "when revoking an access token, given a decoded jwt and an user" do
    let(:exp_time) { Time.now().advance(hours: expiry_hours) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:iat) { Time.now().to_i }
    let(:iss) { jwt_issuer }
    let(:user) { create(:user, id: 1) }
    let!(:refresh_token) { create(:refresh_token, user_id: user.id, jti:) }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti:,
        iat:,
        iss:
      )
    end

    it 'blacklists the token with the right decoded token jti and user' do
      expect { auth_revoker.call }.to change(BlackListedToken.where({ user_id: user.id, jti:, exp: exp_time }), :count).by(1)
    end

    it 'deletes the existing refresh token' do
      expect { auth_revoker.call }.to change(RefreshToken.where({ user_id: user.id, jti: }), :count).from(1).to(0)
    end
  end

  context "when revoking an access token, with an invalid decoded jwt" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp) { Time.now().advance(hours: expiry_hours).to_i }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:iat) { Time.now().to_i }
    let(:iss) { 'localhost.test' }
    let(:user) { create(:user, id: 1) }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        jti:
      )
    end

    it 'raises an Errors::Authentication::InvalidAccessToken error' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end

  context "when revoking an access token that's already revoked" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp_time) { Time.now().advance(hours: expiry_hours) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:iat) { Time.now().to_i }
    let(:iss) { jwt_issuer }
    let(:user) { create(:user, id: 1) }
    let!(:refresh_token) { create(:refresh_token, user_id: user.id, jti:) }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti:,
        iat:,
        iss:
      )
    end
    let!(:black_listed_token) do
      create(:black_listed_token, jti:, user:)
    end

    it 'raises an Authentication::InvalidAccessToken' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end
end
