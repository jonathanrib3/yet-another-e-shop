module Authentication
  class Encoder
    def initialize(user:, jti_registry:)
      @user = user
      @jti_registry = jti_registry
      validate_attributes_presence
    end

    def call
      access_token = JWT.encode(
        {
          sub: @user.id,
          jti:,
          iat:,
          exp:,
          iss:
        },
        Constants::JWT_SECRET,
        Constants::JWT_ALGORITHM_HEADER,
        { typ: Constants::JWT_TYP_HEADER }
      )
      credentials = EncodedJwtAccessTokenCredentials.new(access_token:, jti:, exp:)

      raise Errors::Authentication::InvalidEncodedTokenCredentials, credentials.errors.to_a if credentials.invalid?

      credentials
    end

    private

    def validate_attributes_presence
      raise Errors::Authentication::Encoder::InvalidUser unless @user.instance_of?(User)
    end

    def jti
      @jti_registry.jti
    end

    def exp
      @exp ||= Authentication::Constants::EXPIRY_TIME_IN_HOURS.hours.to_i + iat
    end

    def iat
      @iat ||= Time.current.utc.to_i
    end

    def iss
      @iss ||= Authentication::Constants::JWT_ISSUER
    end
  end
end
