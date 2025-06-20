FactoryBot.define do
  factory :user do
    email { "email@mail.com" }
    password { "123123Qwe." }
    role { 0 }
    confirmed_at { Time.current() }
    confirmation_token { SecureRandom.hex(10) }
    confirmation_sent_at { 2.minutes.ago }

    trait :admin do
      role { 1 }
    end
  end
end
