RSpec.shared_context "current time and authentication constants stubs", shared_context: :metadata do
  include ActiveSupport::Testing::TimeHelpers
  let(:fixed_time) { Time.zone.local(1989, 06, 04) }
  let(:expiry_hours) { 12 }
  let(:refresh_token_expiry_days) { 30 }
  let(:secret) { 'secret' }
  let(:jwt_issuer) { 'localhost.test' }
  let(:jwt_algorithm_header) { 'HS256' }
  let(:jwt_typ_header) { 'JWT' }

  before do
    travel_to fixed_time
    stub_const('Authentication::Constants::EXPIRY_TIME_IN_HOURS', expiry_hours)
    stub_const('Authentication::Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS', refresh_token_expiry_days)
    stub_const('Authentication::Constants::JWT_SECRET', secret)
    stub_const('Authentication::Constants::JWT_ISSUER', jwt_issuer)
    stub_const('Authentication::Constants::JWT_ALGORITHM_HEADER', jwt_algorithm_header)
    stub_const('Authentication::Constants::JWT_TYP_HEADER', jwt_typ_header)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "current time and authentication constants stubs", include_shared: true
end
