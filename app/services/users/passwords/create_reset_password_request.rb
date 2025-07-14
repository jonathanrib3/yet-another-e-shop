module Users
  module Passwords
    class CreateResetPasswordRequest
      def initialize(user:)
        @user = user
      end

      def call
        validate_reset_token_expiration

        ActiveRecord::Base.transaction do
          @user.update!(
            reset_password_sent_at: Time.current,
            reset_password_token:
          )
          UserMailer.reset_password_email(@user).deliver_later
        end

        {
          message: I18n.t('users.password.reset_request_success'),
          expires_at: @user.reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME
        }
      end

      private

      def validate_reset_token_expiration
        return if @user.reset_password_sent_at.nil? || @user.reset_password_token_expired?

        raise Errors::Users::Passwords::CannotResetPasswordBeforeDueExpiration.new(
          expires_at: @user.reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME
        )
      end

      def reset_password_token
        Tokens.generate_random_token
      end
    end
  end
end
