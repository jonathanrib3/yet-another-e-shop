module Errors
  module Authentication
    module Decoder
      class UserNotFound < StandardError
        def initialize(msg = I18n.t('errors.services.authentication.decoder.user_not_found'))
          super(msg)
        end
      end
    end
  end
end
