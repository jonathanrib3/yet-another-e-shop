module Errors
  module Authentication
    class InvalidAccessToken < StandardError
      def initialize(msg = I18n.t('errors.messages.invalid_access_token'))
        super(msg)
      end
    end
  end
end
