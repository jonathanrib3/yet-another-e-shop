module Stripe
  module Constants
    API_KEY = ENV["STRIPE_API_KEY"]
    API_BASE_URL = "https://api.stripe.com/v1".freeze
    IDEMPOTENCY_KEYS_NAME_PREFIX = "idempotency_keys".freeze
  end
end
