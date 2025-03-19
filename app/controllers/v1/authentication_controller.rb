module V1
  class AuthenticationController < V1::ApplicationController
    include Authenticator
    rescue_from Errors::Authentication::Login::InvalidEmailOrPassword, with: :invalid_login

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
      user = User.find(decoded_token.sub)
      Authentication::Revoker.new(decoded_token:, user:).call

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
  end
end
