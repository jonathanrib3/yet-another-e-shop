module Authentication
  class Decoder
    def initialize(access_token:)
      @access_token = access_token
      validate_attributes_presence
    end

    def call
      verify = true
      payload, _header = JWT.decode(@access_token, secret, verify, { verify_iss: true, iss: expected_issuer })
      validate_decoded_user_id(payload["sub"])
      credentials = Authentication::DecodedJwtAccessTokenCredentials.new(
        sub: payload["sub"],
        jti: payload["jti"],
        exp: payload["exp"],
        iat: payload["iat"],
        iss: payload["iss"]
      )

      if credentials.invalid?
        raise Errors::Authentication::InvalidDecodedTokenCredentials, credentials.errors.to_a.join(", ")
      end

      credentials
    end

    private

    def validate_attributes_presence
      raise Errors::Authentication::InvalidAccessToken if @access_token.blank?
    end

    def validate_decoded_user_id(user_id)
      raise Errors::Authentication::InvalidAccessToken unless User.exists?(user_id)
    end

    def secret
      Constants::JWT_SECRET
    end

    def expected_issuer
      Constants::JWT_ISSUER
    end
  end
end
