module Authentication
  class Revoker
    def initialize(decoded_token:, user:)
      @decoded_token = decoded_token
      @user = user
      validate_decoded_token
      validate_user
    end

    def call
      BlackListedToken.create!(
        jti: @decoded_token.jti,
        user_id: @user.id,
        exp: Time.at(@decoded_token.exp)
      )
    end

    private

    def validate_decoded_token
      unless @decoded_token.instance_of?(Authentication::DecodedJwtAccessTokenCredentials) && @decoded_token.valid?
        raise Errors::Authentication::Revoker::InvalidDecodedToken
      end
    end

    def validate_user
      raise Errors::Authentication::Revoker::InvalidUser unless @user.instance_of?(User)
    end

    def validate_token_expiration_date
      raise Errors::Authentication::Refresher::RefreshTokenExpired if Time.now > found_refresh_token.exp
    end

    def found_refresh_token
      @found_refresh_token ||= RefreshToken.includes(:user).find_by!(crypted_token:)
    end

    def crypted_token
      Digest::SHA256.hexdigest(@refresh_token + Constants::JWT_SECRET)
    end

    def new_access_token_credentials
      @new_access_token_credentials ||= Encoder.new(user: found_refresh_token.user).call
    end
  end
end
