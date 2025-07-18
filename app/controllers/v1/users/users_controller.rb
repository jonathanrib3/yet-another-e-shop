module V1
  module Users
    class UsersController < V1::ApplicationController
      include Authenticator

      rescue_from Errors::Users::Verify::InvalidConfirmationToken, with: :invalid_confirmation_token
      before_action :authenticate_user!, only: [:verify]

      def verify
        user = User.find_by!(confirmation_token: params[:token], confirmed_at: nil)
        authorize user
        if Time.current > user.confirmation_token_expires_at
          raise Errors::Users::Verify::InvalidConfirmationToken, I18n.t('errors.messages.invalid_confirmation_token')
        end

        user.update!(confirmed_at: Time.current)

        head :no_content
      rescue ActiveRecord::RecordNotFound,
             ActiveRecord::RecordInvalid
        raise Errors::Users::Verify::InvalidConfirmationToken
      end

      private

      def invalid_confirmation_token(exception)
        @message = exception.message

        render template: 'v1/error/error', status: :unprocessable_entity
      end
    end
  end
end
