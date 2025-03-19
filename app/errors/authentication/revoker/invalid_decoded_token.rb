module Errors
  module Authentication
    module Revoker
      class InvalidDecodedToken < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.revoker.invalid_decoded_token"))
          super
        end
      end
    end
  end
end
