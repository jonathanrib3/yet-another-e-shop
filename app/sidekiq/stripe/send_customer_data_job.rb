module Stripe
  class SendCustomerDataJob
    include Sidekiq::Job
    sidekiq_options retry: 3

    def perform(customer_id)
      customer = ::Customer.includes(:addresses).find(customer_id)
      idempotency_key = Stripe::FindOrCreateIdempotencyKey.new(
        operation: "create",
        customer_id:,
        idempotency_keys_repository:
      ).call
      result = Stripe::CreateCustomer.new(customer:, idempotency_key:).call

      customer.update!(stripe_customer_id: result[:id])
    end

    private

    def idempotency_keys_repository
      @idempotency_keys_repository ||= IdempotencyKeysRepository.new
    end
  end
end
