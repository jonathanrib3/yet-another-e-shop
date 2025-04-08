# /home/jonathan/Workspace/yet-another-e-shop/app/services/stripe/create_idempotency_key.rb

module Stripe
  class FindOrCreateIdempotencyKey
    VALID_OPERATIONS = [ "create", "update", "delete" ].freeze

    def initialize(idempotency_keys_repository:, customer_id:, operation:)
      @idempotency_keys_repository = idempotency_keys_repository
      @customer_id = customer_id
      @operation = operation
      validate_operation
    end

    def call
      idempotency_key = @idempotency_keys_repository.find_by_name(
        idempotency_key_name
      )
      if idempotency_key.blank?
        idempotency_key = @idempotency_keys_repository.create(name: idempotency_key_name, value: idempotency_key_value)
      end

      idempotency_key
    end

    private

    def idempotency_key_value
      @idempotency_key_value ||= Digest::UUID.uuid_v4
    end

    def idempotency_key_name
      @idempotency_key_name ||= "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:#{@operation}_customer_#{@customer_id}"
    end

    def validate_operation
      unless VALID_OPERATIONS.include?(@operation)
        raise Errors::Stripe::FindOrCreateIdempotencyKey::InvalidOperation
      end
    end
  end
end
