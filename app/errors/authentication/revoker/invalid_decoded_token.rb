module Errors
  module Authentication
    class InvalidDecodedToken < StandardError
      def initialize(msg = I18n.t("errors.services.authentication.revoker.invalid_decoded_token"))
        super(msg)
      end
    end
  end
end
