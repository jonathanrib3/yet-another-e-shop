class Address < ApplicationRecord
  enum :address_type, [ :residential, :shipping, :billing ], validation: true

  validates :line_1, :zip_code, :city, :state, :country, presence: true
  validates :customer_id, uniqueness: {
    case_sensitive: false,
    message: I18n.t("errors.address.attributes.user_id.duplicate_residential_address")
  }, if: -> { address_type.present? && residential? }

  belongs_to :customer
end
