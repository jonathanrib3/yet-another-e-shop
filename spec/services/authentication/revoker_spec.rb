require 'rails_helper'

RSpec.describe Authentication::Revoker, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  subject(:auth_revoker) { described_class.new(decoded_token:, user:) }

  context "when revoking an access token, given a decoded jwt and an user" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp_time) { Time.now().advance(hours: expiry_hours) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:iat) { Time.now().to_i }
    let(:iss) { 'localhost.test' }
    let(:user) { create(:user, id: 1) }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: user.id,
        exp: exp_time.to_i,
        jti:,
        iat:,
        iss:
      )
    end
    let(:expiry_hours) { 12 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', iss)
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      travel_to(fixed_time)
    end

    it 'blacklists the token with the right decoded token jti and user' do
      expect { auth_revoker.call }.to change(BlackListedToken.where({ user_id: user.id, jti:, exp: exp_time }), :count).by(1)
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
    let(:expiry_hours) { 12 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', 'localhost.test')
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      travel_to(fixed_time)
    end

    it 'raises an Authentication::Revoker::InvalidDecodedToken error' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::Revoker::InvalidDecodedToken)
    end
  end

  context "when revoking an access token, with an invalid user" do
    let(:fixed_time) { Time.new(1989, 06, 04) }
    let(:exp_time) { Time.now().advance(hours: expiry_hours) }
    let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
    let(:iat) { Time.now().to_i }
    let(:iss) { 'localhost.test' }
    let(:user) { nil }
    let(:decoded_token) do
      Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: 1,
        exp: exp_time.to_i,
        jti:,
        iat:,
        iss:
      )
    end
    let(:expiry_hours) { 12 }

    before do
      stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
      stub_const('Authentication::Constants::JWT_SECRET', 'secret')
      stub_const('Authentication::Constants::JWT_ISSUER', iss)
      stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', 'HS256')
      stub_const('Authentication::Constants::JWT_TYP_HEADER', 'JWT')
      travel_to(fixed_time)
    end

    it 'raises an Authentication::Revoker::InvalidUser error' do
      expect { auth_revoker.call }.to raise_error(Errors::Authentication::Revoker::InvalidUser)
    end
  end
end
