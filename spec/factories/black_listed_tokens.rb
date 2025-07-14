FactoryBot.define do
  factory :black_listed_token do
    exp { '2025-03-21 09:14:38' }
    jti_registry
  end
end
