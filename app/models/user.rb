class User < ApplicationRecord
  include ActiveModel::SecurePassword
  EMAIL_VALIDATION_REGEX = /\A[^.][\w\-_.]*[^.]@(?=[^@]*[a-zA-Z]\b\.\b)([\w-]+\.)+[a-zA-Z]{2,}\z/
  PASSWORD_VALIDATION_REGEX = %r{(?=.*[A-ZÁÉÍÓÚÃÕÊÀÈÌÒ])(?=.*[a-záéíóúãõêàèìò])(?=.*[0-9])(?=.*[-_.*+/%&$@!'"()^~#\\])}

  has_secure_password reset_token: true

  enum :role, { customer: 0, admin: 1 }, validate: true
  validates :email, uniqueness: true, format: { with: EMAIL_VALIDATION_REGEX }
  validates :password, format: { with: PASSWORD_VALIDATION_REGEX }, if: -> { will_save_change_to_password_digest? }

  has_many :jti_registries, dependent: :destroy
  has_many :black_listed_tokens, through: :jti_registries

  def confirmed?
    confirmed_at.present?
  end
end
