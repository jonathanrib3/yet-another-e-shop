module Authentication
  class Revoker
    def initialize(decoded_token:, user:)
      @decoded_token = decoded_token
      @user = user
      validate_decoded_token
    end

    def call
      ActiveRecord::Base.transaction do
        validate_token_already_black_listed

        BlackListedToken.create!(
          jti: @decoded_token.jti,
          user_id: @user.id,
          exp: Time.at(@decoded_token.exp)
        )

        refresh_token.destroy!
      end
    end

    private

    def refresh_token
      @refresh_token ||= RefreshToken.find_by(user_id: @user.id)
    end

    def validate_decoded_token
      unless @decoded_token.instance_of?(Authentication::DecodedJwtAccessTokenCredentials) && @decoded_token.valid?
        raise Errors::Authentication::InvalidAccessToken
      end
    end

    def validate_token_already_black_listed
      blacklistedtoken = BlackListedToken.find_by(jti: @decoded_token.jti)

      raise Errors::Authentication::InvalidAccessToken if blacklistedtoken.present?
    end
  end
end
