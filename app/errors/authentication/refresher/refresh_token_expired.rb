module Errors
  module Authentication
    module Refresher
      class RefreshTokenExpired < StandardError
        def initialize(msg = I18n.t("errors.services.authentication.refresher.refresh_token_expired"))
          super(msg)
        end
      end
    end
  end
end
