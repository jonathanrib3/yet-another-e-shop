FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "123123Qwe." }
    role { 0 }
    confirmed_at { Time.now() }
    confirmation_token { SecureRandom.hex(10) }
    confirmation_sent_at { 2.minutes.ago }
    reset_password_token { nil }
    reset_password_sent_at { nil }

    trait :admin do
      role { 1 }
    end
  end
end
