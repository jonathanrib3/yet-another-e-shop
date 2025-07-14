module Errors
  module Authentication
    module Revoker
      class TokenAlreadyBlackListed < StandardError
        def initialize(msg = I18n.t('errors.services.authentication.revoker.token_already_black_listed'))
          super(msg)
        end
      end
    end
  end
end
