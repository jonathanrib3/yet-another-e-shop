module Errors
  module Authentication
    module Authenticator
      class InvalidUser < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.authenticator.invalid_user"))
          super(msg)
        end
      end
    end
  end
end
