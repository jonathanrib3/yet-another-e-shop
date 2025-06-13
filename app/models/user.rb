class User < ApplicationRecord
  include ActiveModel::SecurePassword
  EMAIL_VALIDATION_REGEX = /\A[^.][\w\-_.]*[^.]@(?=[^@]*[a-zA-Z]\b\.\b)([\w-]+\.)+[a-zA-Z]{2,}\z/
  PASSWORD_VALIDATION_REGEX = %r{(?=.*[A-ZÁÉÍÓÚÃÕÊÀÈÌÒ])(?=.*[a-záéíóúãõêàèìò])(?=.*[0-9])(?=.*[-_.*+/%&$@!'"()^~#\\])}
  RESET_PASSWORD_TOKEN_EXPIRATION_TIME = 10.minutes

  has_secure_password reset_token: true

  enum :role, { customer: 0, admin: 1 }, validate: true
  validates :email, uniqueness: true, format: { with: EMAIL_VALIDATION_REGEX }
  validates :password, format: { with: PASSWORD_VALIDATION_REGEX }, if: -> { will_save_change_to_password_digest? }

  has_many :jti_registries, dependent: :destroy
  has_many :black_listed_tokens, through: :jti_registries

  def reset_password_token_expired?
    return false unless reset_password_sent_at.present?

    Time.now >= (reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME)
  end

  def confirmed?
    confirmed_at.present?
  end
end
