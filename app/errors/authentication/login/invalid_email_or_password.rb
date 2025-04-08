module Errors
  module Authentication
    module Login
      class InvalidEmailOrPassword < StandardError
        def initialize(msg = I18n.t("errors.messages.invalid_login"))
          super(msg)
        end
      end
    end
  end
end
