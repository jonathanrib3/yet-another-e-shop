FactoryBot.define do
  factory :user do
    email { "email@mail.com" }
    password { "123123Qwe." }
    role { 0 }
  end
end
