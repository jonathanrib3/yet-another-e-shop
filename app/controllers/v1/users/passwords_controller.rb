module V1
  module Users
    class PasswordsController < V1::ApplicationController
      rescue_from Errors::Users::Passwords::CannotResetPasswordBeforeDueExpiration, with: :handle_reset_password_before_due_expiration
      def reset
        user = User.find_by!(email: params[:email])
        result = ::Users::Passwords::CreateResetPasswordRequest.new(user:).call
        @message = result[:message]
        @expires_at = result[:expires_at]

        render status: :created
      end

      def cancel
        user = User.find_by!(reset_password_token: params[:token])

        if user.reset_password_token_expired?
          @message = I18n.t("errors.users.password.cannot_cancel_expired_reset_request")

          return render template: "v1/error/error", status: :unprocessable_entity
        end

        user.update!(reset_password_token: nil)

        head :no_content
      end

      def update
        user = User.find_by!(reset_password_token: update_password_params["reset_password_token"])

        if user.reset_password_token_expired?
          @message = I18n.t("errors.users.password.reset_password_token_expired")

          return render template: "v1/error/error", status: :unprocessable_entity
        end

        user.update!(**update_password_params, reset_password_token: nil, reset_password_sent_at: nil)

        head :no_content
      end

      private

      def update_password_params
        params.require(:user).permit(:password, :reset_password_token)
      end

      def record_not_found(exception)
        if exception.message.include?("[WHERE \"users\".\"email\" = $1]")
          @message = I18n.t("errors.users.password.reset_request_email_not_found")
        else
          @message = I18n.t("errors.users.password.reset_request_token_not_found")
        end

        render template: "v1/error/error", status: :not_found
      end

      def handle_reset_password_before_due_expiration(exception)
        render json: { message: exception.message, expires_at: exception.expires_at }, status: :unprocessable_entity
      end

      def user
        
      end
    end
  end
end
