FactoryBot.define do
  factory :address do
    line_1 { "R. Oscar Menezes de Freitas" }
    line_2 { "86 - Centro" }
    zip_code { "58200-000" }
    city { "Guarabira" }
    state { "Paraíba" }
    country { "Brazil" }
    address_type { :residential }
    customer
  end
end
