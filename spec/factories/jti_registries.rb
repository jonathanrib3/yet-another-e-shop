FactoryBot.define do
  factory :jti_registry do
    jti { Digest::UUID.uuid_v4 }
    user
  end
end
