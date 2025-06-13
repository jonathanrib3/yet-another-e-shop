FactoryBot.define do
  factory :customer do
    first_name { "John" }
    last_name { "Doe" }
    phone_number { "+55111203912" }
    document_number { "111.111.111-11" }
    document_type { "cpf" }
    date_of_birth { Date.new(1989, 06, 04) }
    stripe_customer_id { nil }
    user

    trait :with_addresses do
      addresses do
        [
          build(:address, address_type: :residential, customer: instance),
          build(:address, address_type: :shipping, customer: instance),
          build(:address, address_type: :billing, customer: instance)
        ]
      end
    end
  end
end
