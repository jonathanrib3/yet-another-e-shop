module Authentication
  class Issuer
    def initialize(user:)
      @user = user
      validate_user
    end

    def call
      delete_previous_refresh_token_if_any
      RefreshToken.create!(
        user_id: @user.id,
        jti: access_token_credentials.jti,
        crypted_token:,
        exp:
      )

      EncodedJwtAccessAndRefreshTokenCredentials.new(
        access_token: access_token_credentials.access_token,
        refresh_token: raw_refresh_token)
    end

    private

    def validate_user
      raise Errors::Authentication::Issuer::InvalidUser unless @user.instance_of?(User)
    end

    def delete_previous_refresh_token_if_any
      previous_refresh_token = RefreshToken.find_by(user_id: @user.id)
      previous_refresh_token.destroy! if previous_refresh_token.present?
    end

    def access_token_credentials
      @access_token_credentials ||= Authentication::Encoder.new(user: @user).call
    end

    def raw_refresh_token
      @raw_refresh_token ||= Tokens.generate_random_token
    end

    def exp
      Time.now.advance(days: Constants::REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS)
    end

    def crypted_token
      Digest::SHA256.hexdigest(raw_refresh_token +  Constants::JWT_SECRET)
    end
  end
end
