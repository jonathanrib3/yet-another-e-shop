module Errors
  module Stripe
    module FindOrCreateIdempotencyKey
      class InvalidOperation < StandardError
        def initialize(msg = I18n.t("errors.services.stripe.find_or_create_idempotency_key.invalid_operation"))
          super
        end
      end
    end
  end
end
