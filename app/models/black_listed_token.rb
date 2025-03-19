class BlackListedToken < ApplicationRecord
  validates :jti, :exp, presence: true
  validates :user_id, uniqueness: true

  belongs_to :user
end
