require 'rails_helper'

RSpec.describe Authentication::Revoker, type: :service do
  include_context "current time and authentication constants stubs"

  subject(:auth_revoker) { described_class.new(jti:) }

  context "when revoking an access token, given a valid jti" do
    let(:exp_time) { fixed_time.advance(hours: expiry_hours) }
    let(:user) { create(:user, id: 1) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let!(:jti_registry) { create(:jti_registry, jti:, user:) }
    let(:iat) { fixed_time.to_i }
    let(:iss) { jwt_issuer }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti: jti_registry.jti,
        iat:,
        iss:
      )
    end

    before do
      create(:refresh_token, jti_registry:)
    end

    it 'blacklists the token with the right jti' do
      expect { auth_revoker.call }.to change(BlackListedToken.where({ jti: jti_registry.jti, exp: exp_time }), :count).by(1)
    end

    it 'deletes the existing refresh token' do
      expect { auth_revoker.call }.to change(RefreshToken.where({ jti: jti_registry.jti }), :count).from(1).to(0)
    end
  end

  context "when revoking an access token, with an invalid jti" do
    let(:user) { create(:user, id: 1) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:jti_registry) { create(:jti_registry, jti:, user:) }

    it 'raises an Errors::Authentication::InvalidAccessToken error' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end

  context "when revoking an access token, with an invalid jit inside jwt" do
    let(:exp_time) { fixed_time.advance(hours: expiry_hours) }
    let(:user) { create(:user, id: 1) }
    let(:iat) { fixed_time.to_i }
    let(:jti) { "invalid jti" }
    let(:iss) { jwt_issuer }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti:,
        iat:,
        iss:
      )
    end

    it 'raises an Errors::Authentication::InvalidAccessToken error' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::InvalidAccessToken)
    end
  end

  context "when revoking an access token that's already revoked" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp_time) { fixed_time.advance(hours: expiry_hours) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:jti_registry) { create(:jti_registry, jti:, user:) }
    let(:iat) { fixed_time.to_i }
    let(:iss) { jwt_issuer }
    let(:user) { create(:user, id: 1) }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti: jti_registry.jti,
        iat:,
        iss:
      )
    end

    before do
      create(:black_listed_token, jti_registry:)
      create(:refresh_token, jti_registry:)
    end

    it 'raises an Authentication::Revoker::TokenAlreadyBlackListed' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::Revoker::TokenAlreadyBlackListed)
    end
  end
end
