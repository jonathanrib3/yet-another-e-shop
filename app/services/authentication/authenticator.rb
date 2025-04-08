module Authentication
  class Authenticator
    def initialize(access_token:)
      @access_token = access_token
    end

    def call
      validate_issuer
      validate_black_listed_token

      User.find(decoded_token.sub)
    rescue ActiveRecord::RecordNotFound
      raise Errors::Authentication::InvalidAccessToken
    end

    private

    def decoded_token
      @decoded_token ||= Decoder.new(access_token: @access_token).call
    end

    def validate_black_listed_token
      black_listed_token = BlackListedToken.find_by(jti: decoded_token.jti)

      if black_listed_token.present?
        raise Errors::Authentication::InvalidAccessToken
      end
    end

    def validate_issuer
      raise Errors::Authentication::InvalidAccessToken if decoded_token.iss != Constants::JWT_ISSUER
    end
  end
end
