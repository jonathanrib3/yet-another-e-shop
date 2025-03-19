module Authentication
  class EncodedJwtAccessTokenCredentials
    include ActiveModel::Model

    attr_accessor :access_token, :jti, :exp

    validates :access_token, :jti, presence: true
    validates :exp, numericality: { only_integer: true }
  end
end
