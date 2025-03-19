module Authentication
  class Refresher
    def initialize(refresh_token:)
      @refresh_token = refresh_token
      validate_presence_of_refresh_token
    end

    def call
      validate_token_expiration_date

      EncodedJwtAccessAndRefreshTokenCredentials.new(
        access_token: new_access_token_credentials.access_token,
        refresh_token: @refresh_token
      )
    end

    private

    def validate_presence_of_refresh_token
      raise Errors::Authentication::Refresher::RefreshTokenNotFound  if @refresh_token.blank?
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
