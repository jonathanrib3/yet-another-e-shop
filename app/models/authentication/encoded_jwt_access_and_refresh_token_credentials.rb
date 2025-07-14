module Authentication
  class EncodedJwtAccessAndRefreshTokenCredentials
    include ActiveModel::Model

    attr_accessor :access_token, :refresh_token

    validates :access_token, :refresh_token, presence: true
  end
end
