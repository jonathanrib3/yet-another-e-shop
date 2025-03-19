class RefreshToken < ApplicationRecord
  validates :crypted_token, :exp, presence: true
  validates :user_id, uniqueness: true

  belongs_to :user
end
