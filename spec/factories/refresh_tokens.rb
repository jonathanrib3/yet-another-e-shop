FactoryBot.define do
  factory :refresh_token do
    crypted_token { 'some_token' }
    exp { '2025-03-21 09:15:06' }
    jti_registry
  end
end
