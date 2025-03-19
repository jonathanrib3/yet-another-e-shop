module Errors
  module Authentication
    module Issuer
      class InvalidUser < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.issuer.invalid_user"))
          super
        end
      end
    end
  end
end
