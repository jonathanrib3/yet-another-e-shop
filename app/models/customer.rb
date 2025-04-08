class Customer < ApplicationRecord
  CPF_FORMAT_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/.freeze
  RG_FORMAT_REGEX = /\A\d{2}\.\d{3}\.\d{3}\-[\dXx]{1,2}$\z/.freeze
  PASSPORT_FORMAT_REGEX = /\A[A-Z]{2}\d{6}$\z/.freeze

  enum :document_type, [ :cpf, :rg, :passport ], validate: true

  validates :first_name, :last_name, :phone_number, :date_of_birth, presence: true
  validates :document_number, presence: true, uniqueness: { case_sensitive: false }
  validate :document_number_format, if: -> { document_number.present? && document_type.present? }
  validate :validate_residential_addresses

  belongs_to :user
  has_many :addresses
  accepts_nested_attributes_for :addresses, :user

  def residential_address
    addresses.select { |address| address.residential? }.first
  end

  private

  def document_number_format
    case document_type
    when "cpf"
      validate_cpf_format
    when "rg"
      validate_rg_format
    when "passport"
      validate_passport_format
    else
      errors.add(:document_type, :invalid)
    end
  end

  def validate_cpf_format
    unless document_number.match?(CPF_FORMAT_REGEX)
      errors.add(:document_number, :invalid_cpf_format)
    end
  end

  def validate_rg_format
    unless document_number.match?(RG_FORMAT_REGEX)
      errors.add(:document_number, :invalid_rg_format)
    end
  end

  def validate_passport_format
    unless document_number.match?(PASSPORT_FORMAT_REGEX)
      errors.add(:document_number, :invalid_passport_format)
    end
  end

  def validate_residential_addresses
    return if addresses.blank?

    residential_addresses = addresses.group_by(&:residential?)[true]

    unless residential_addresses.blank? || residential_addresses.length == 1
      errors.add(:addresses, I18n.t("errors.address.attributes.user_id.duplicate_residential_address"))
    end
  end
end
