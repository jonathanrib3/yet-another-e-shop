module Authentication
  class DecodedJwtAccessTokenCredentials
    include ActiveModel::Model

    attr_accessor :sub, :jti, :exp, :iat, :iss

    validates :jti, :iss, presence: true
    validates :sub, :iat, :exp, numericality: { only_integer: true }
  end
end
