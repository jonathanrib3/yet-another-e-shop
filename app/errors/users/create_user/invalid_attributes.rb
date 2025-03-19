module Errors
  module Users
    module CreateUser
      class InvalidAttributes < StandardError
        def initialize(msg = I18n.t("errors.services.create_user.invalid_attributes"))
          super
        end
      end
    end
  end
end
