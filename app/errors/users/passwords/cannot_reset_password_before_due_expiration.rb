module Errors
  module Users
    module Passwords
      class CannotResetPasswordBeforeDueExpiration < StandardError
        def initialize(msg: I18n.t("errors.users.password.cannot_reset_password_before_due_expiration"), expires_at: nil)
          @expires_at = expires_at
          super(msg)
        end

        attr_reader :expires_at
      end
    end
  end
end
