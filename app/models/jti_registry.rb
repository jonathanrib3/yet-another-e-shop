class JtiRegistry < ApplicationRecord
  self.primary_key = :jti

  belongs_to :user
  has_one :refresh_token, dependent: :destroy, foreign_key: :jti, primary_key: :jti, inverse_of: :jti_registry
  has_one :black_listed_token, dependent: :destroy, foreign_key: :jti, primary_key: :jti, inverse_of: :jti_registry
end
