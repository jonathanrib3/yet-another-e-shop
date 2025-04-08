module Authenticator
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::Authentication::InvalidRefreshToken, with: :invalid_refresh_token
    rescue_from Errors::Authentication::InvalidAccessToken, with: :invalid_access_token
    rescue_from NoMatchingPatternError, with: :invalid_access_token
  end

  def authenticate_user!
    set_jti_registry
    raise Errors::Authentication::InvalidAccessToken if @jti_registry.black_listed_token.present?

    true
  rescue ActiveRecord::RecordNotFound
    raise Errors::Authentication::InvalidAccessToken
  end

  def current_user
    @current_user ||= @jti_registry.user
  end

  def access_token
    @access_token ||= (
      matches = Authentication::Constants::JWT_ACCESS_TOKEN_RETRIEVAL_REGEX.match(request.headers["Authorization"])

      raise Errors::Authentication::InvalidAccessToken if matches.nil?

      matches[:access_token]
    )
  end

  def decoded_token
    @decoded_token ||= Authentication::Decoder.new(access_token:).call
  end

  private

  def set_jti_registry
    @jti_registry ||= JtiRegistry.includes(:user, :black_listed_token)
      .find_by!(jti: decoded_token.jti, user_id: decoded_token.sub)
  end

  def invalid_refresh_token(exception)
    @message = exception.message
    render template: "v1/error/error", status: :unauthorized
  end

  def invalid_access_token(exception)
    @message = exception.message
    render template: "v1/error/error", status: :unauthorized
  end
end
