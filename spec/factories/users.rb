FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "123123Qwe." }
    role { 0 }
    confirmation_token { SecureRandom.hex(10) }
    confirmed_at { Time.current }
    confirmation_sent_at { 2.minutes.ago }
    confirmation_token_expires_at { 5.minutes.from_now }
    reset_password_token { nil }
    reset_password_sent_at { nil }
    reset_password_token_expires_at { nil }

    trait :admin do
      role { 1 }
    end
  end
end
