module Errors
  module Authentication
    class InvalidRefreshToken < StandardError
      def initialize(msg = I18n.t('errors.messages.invalid_refresh_token'))
        super(msg)
      end
    end
  end
end
