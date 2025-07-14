class BlackListedToken < ApplicationRecord
  validates :jti, :exp, presence: true
  validates :jti, uniqueness: true

  belongs_to :jti_registry, foreign_key: :jti, primary_key: :jti, inverse_of: :black_listed_token
end
