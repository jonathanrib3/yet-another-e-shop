module Authenticator
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::Authentication::InvalidRefreshToken, with: :invalid_refresh_token
    rescue_from Errors::Authentication::InvalidAccessToken, with: :invalid_access_token
    rescue_from NoMatchingPatternError, with: :invalid_access_token
  end

  def authenticate_user!
    raise Errors::Authentication::InvalidAccessToken unless User.exists?(decoded_token.sub)

    true
  end

  def current_user
    return unless access_token

    @current_user ||= User.find(decoded_token.sub)
  rescue ActiveRecord::RecordNotFound
    raise Errors::Authentication::InvalidAccessToken
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

  def invalid_refresh_token(exception)
    @message = exception.message
    render template: "v1/error/error", status: :unauthorized
  end

  def invalid_access_token(exception)
    @message = exception.message
    render template: "v1/error/error", status: :unauthorized
  end
end
