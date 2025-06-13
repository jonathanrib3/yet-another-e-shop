module V1
  class AuthenticationController < V1::ApplicationController
    include Authenticator
    rescue_from Errors::Authentication::Login::InvalidEmailOrPassword, with: :invalid_login
    rescue_from Errors::Authentication::Revoker::TokenAlreadyBlackListed, with: :handle_token_already_black_listed
    rescue_from Errors::Authentication::InvalidRefreshToken, with: :invalid_refresh_token

    def authenticate
      @credentials = Authentication::Login.new(email: user_params["email"], password: user_params["password"]).call

      render json: @credentials
    end

    def refresh_token
      @credentials = Authentication::Refresher.new(refresh_token: refresh_token_params).call

      render json: @credentials
    end

    def logout
      decoded_token = Authentication::Decoder.new(access_token:).call
      Authentication::Revoker.new(jti: decoded_token.jti).call

      head :no_content
    end

    private

    def user_params
      params.require(:user).permit(:email, :password)
    end

    def refresh_token_params
      params.require(:refresh_token)
    end

    def invalid_login(exception)
      @message = exception.message
      render template: "v1/error/error", status: :unauthorized
    end

    def handle_token_already_black_listed
      @message = I18n.t("errors.services.authentication.revoker.token_already_black_listed")
      render template: "v1/error/error", status: :unprocessable_entity
    end

    def invalid_refresh_token(exception)
      @message = exception.message
      render template: "v1/error/error", status: :unauthorized
    end
  end
end
