module Errors
  module Authentication
    module Revoker
      class InvalidUser < StandardError
        def initialize(msg = I18n.t('errors.services.authentication.revoker.invalid_user'))
          super(msg)
        end
      end
    end
  end
end
