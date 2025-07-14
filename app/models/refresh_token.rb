class RefreshToken < ApplicationRecord
  validates :crypted_token, :exp, presence: true

  belongs_to :jti_registry, foreign_key: :jti, primary_key: :jti, inverse_of: :refresh_token
end
