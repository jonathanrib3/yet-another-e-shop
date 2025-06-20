module Authentication
  class Revoker
    def initialize(jti:)
      @jti = jti
    end

    def call
      ActiveRecord::Base.transaction do
        validate_token_already_black_listed
        refresh_token.destroy! if refresh_token.present?

        BlackListedToken.create!(
          exp:,
          jti_registry:
        )
      end
    end

    private

    def jti_registry
      @jti_registry ||= JtiRegistry.includes(:refresh_token, :black_listed_token).find_by!(jti: @jti)
    rescue ActiveRecord::RecordNotFound
      raise Errors::Authentication::InvalidAccessToken
    end

    def validate_token_already_black_listed
      raise Errors::Authentication::Revoker::TokenAlreadyBlackListed if jti_registry.black_listed_token.present?
    end

    def refresh_token
      @refresh_token ||= jti_registry.refresh_token
    end

    def exp
      @exp ||= Time.current.advance(hours: Authentication::Constants::EXPIRY_TIME_IN_HOURS)
    end
  end
end
