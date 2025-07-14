module Errors
  module Authentication
    module Encoder
      class InvalidUser < StandardError
        def initialize(msg = I18n.t('errors.services.authentication.encoder.invalid_user'))
          super
        end
      end
    end
  end
end
