FactoryBot.define do
  factory :user do
    email { "email@mail.com" }
    password { "123123Qwe." }
    role { 0 }
    confirmed_at { Time.now() }
    confirmation_sent_at { 2.minutes.ago }
  end
end
