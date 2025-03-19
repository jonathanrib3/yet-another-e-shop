class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password reset_token: true

  enum :role, [ :customer, :admin ]
  validates :email, uniqueness: true, format: {
    with: /\A[^.][\w\-_.]*[^.]@(?=[^@]*[a-zA-Z]\b\.\b)([\w\-]+\.)+[a-zA-Z]{2,}\z/
  }
  validates :password, format: {
    with: /(?=.*[A-ZÁÉÍÓÚÃÕÊÀÈÌÒ])(?=.*[a-záéíóúãõêàèìò])(?=.*[0-9])(?=.*[\-_.*+\/%&$@!'"()^~#\\])/
  }
end

