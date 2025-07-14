module Errors
  module Authentication
    module Decoder
      class BlankAccessToken < StandardError
        def initialize(msg = I18n.t('errors.services.authentication.decoder.blank_access_token'))
          super(msg)
        end
      end
    end
  end
end
