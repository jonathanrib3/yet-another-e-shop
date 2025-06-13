class Address < ApplicationRecord
  enum :address_type, [ :residential, :shipping, :billing ], validate: true

  validates :line_1, :zip_code, :city, :state, :country, presence: true
  validates :address_type, inclusion: { in: address_types.keys }

  belongs_to :customer
end
