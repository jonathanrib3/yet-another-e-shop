module Errors
  module Authentication
    module Refresher
      class RefreshTokenNotFound < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.refresher.refresh_token_not_found"))
          super
        end
      end
    end
  end
end
