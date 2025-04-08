module Authentication
  class Issuer
    def initialize(user:)
      @user = user
      validate_user
    end

    def call
      delete_previous_jti_registry_if_any
      RefreshToken.create!(
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

    def delete_previous_jti_registry_if_any
      previous_jti_registry = JtiRegistry.find_by(user_id: @user.id)
      previous_jti_registry.destroy! if previous_jti_registry.present?
    end

    def access_token_credentials
      @access_token_credentials ||= Authentication::Encoder.new(user: @user, jti_registry:).call
    end

    def jti_registry
      @jti_registry ||= JtiRegistry.create!(
        jti: Digest::UUID.uuid_v4,
        user: @user,
      )
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
