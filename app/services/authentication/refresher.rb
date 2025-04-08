module Authentication
  class Refresher
    def initialize(refresh_token:)
      @refresh_token = refresh_token
    end

    def call
      validate_token_expiration_date

      EncodedJwtAccessAndRefreshTokenCredentials.new(
        access_token: new_access_token_credentials.access_token,
        refresh_token: @refresh_token
      )
    end

    private

    def validate_token_expiration_date
      raise Errors::Authentication::InvalidRefreshToken if Time.now > found_refresh_token.exp
    end

    def found_refresh_token
      @found_refresh_token ||= RefreshToken.includes(jti_registry: :user).find_by!(crypted_token:)
    rescue ActiveRecord::RecordNotFound
      raise Errors::Authentication::InvalidRefreshToken
    end

    def crypted_token
      Digest::SHA256.hexdigest(@refresh_token + Constants::JWT_SECRET)
    end

    def new_access_token_credentials
      @new_access_token_credentials ||= Encoder.new(
        user: found_refresh_token.jti_registry.user,
        jti_registry: found_refresh_token.jti_registry
      ).call
    end
  end
end
