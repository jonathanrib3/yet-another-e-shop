# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
4.times do |index|
  User.create!(
    email: "customer_#{index}@mail.com",
    password: '123123Qwe.',
    confirmation_token: Tokens.generate_random_token,
    confirmation_sent_at: Time.current,
    confirmed_at: Time.current
  )
end

User.create!(
  email: 'admin@mail.com',
  password: '123123Qwe.',
  role: :admin,
  confirmation_sent_at: Time.current,
  confirmed_at: Time.current
)
