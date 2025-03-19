module Errors
  module Authentication
    module Authenticator
      class InvalidToken < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.authenticator.invalid_token"))
          super
        end
      end
    end
  end
end
