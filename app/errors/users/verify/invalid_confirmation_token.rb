module Errors
  module Users
    module Verify
      class InvalidConfirmationToken < StandardError
        def initialize(msg = I18n.t('errors.messages.invalid_confirmation_token'))
          super
        end
      end
    end
  end
end
