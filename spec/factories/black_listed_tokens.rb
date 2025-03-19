FactoryBot.define do
  factory :black_listed_token do
    jti { "MyIdentifier" }
    exp { "2025-03-21 09:14:38" }
    user
  end
end
