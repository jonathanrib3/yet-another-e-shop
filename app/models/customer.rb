class Customer < ApplicationRecord
  CPF_FORMAT_REGEX = /\A\d{3}\.\d{3}\.\d{3}-\d{2}\z/
  RG_FORMAT_REGEX = /\A\d{2}\.\d{3}\.\d{3}-[\dXx]{1,2}$\z/
  PASSPORT_FORMAT_REGEX = /\A[A-Z]{2}\d{6}$\z/

  enum :document_type, { cpf: 0, rg: 1, passport: 2 }, validate: true

  validates :first_name, :last_name, :phone_number, :date_of_birth, presence: true
  validates :document_number, presence: true, uniqueness: { case_sensitive: false }
  validate :document_number_format, if: -> { document_number.present? && document_type.present? }
  validate :residential_addresses_uniqueness
  validate :billing_addresses_uniqueness

  belongs_to :user, dependent: :destroy
  has_many :addresses, dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :user, reject_if: :all_blank

  def residential_address
    addresses.find(&:residential?)
  end

  def billing_address
    addresses.find(&:billing?)
  end

  def shipping_addresses
    addresses.filter(&:shipping?)
  end

  private

  def document_number_format
    case document_type
    when 'cpf'
      validate_cpf_format
    when 'rg'
      validate_rg_format
    when 'passport'
      validate_passport_format
    else
      errors.add(:document_type, :invalid)
    end
  end

  def validate_cpf_format
    return if document_number.match?(CPF_FORMAT_REGEX)

    errors.add(:document_number, :invalid_cpf_format)
  end

  def validate_rg_format
    return if document_number.match?(RG_FORMAT_REGEX)

    errors.add(:document_number, :invalid_rg_format)
  end

  def validate_passport_format
    return if document_number.match?(PASSPORT_FORMAT_REGEX)

    errors.add(:document_number, :invalid_passport_format)
  end

  def residential_addresses_uniqueness
    return if addresses.blank?

    residential_addresses = addresses.group_by(&:residential?)[true]

    return unless residential_addresses.present? && residential_addresses.length > 1

    errors.add(:addresses, I18n.t('errors.address.attributes.user_id.duplicate_residential_address'))
  end

  def billing_addresses_uniqueness
    return if addresses.blank?

    billing_addresses = addresses.group_by(&:billing?)[true]

    return unless billing_addresses.present? && billing_addresses.length > 1

    errors.add(:addresses, I18n.t('errors.address.attributes.user_id.duplicate_billing_address'))
  end
end
