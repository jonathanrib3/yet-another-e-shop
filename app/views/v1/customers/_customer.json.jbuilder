json.customer do
  json.user do
    json.email @customer.user.email
  end
  json.first_name @customer.first_name
  json.last_name @customer.last_name
  json.phone_number @customer.phone_number
  json.document_number @customer.document_number
  json.document_type @customer.document_type
  json.date_of_birth @customer.date_of_birth.strftime("%Y-%m-%d")
  json.addresses @customer.addresses
  json.created_at @customer.created_at
  json.updated_at @customer.updated_at
end
