module Stripe
  class CreateCustomer
    def initialize(customer:, idempotency_key:)
      @customer = customer
      @idempotency_key = idempotency_key
    end

    def call
      created_customer = Stripe::Customer.create(
        customer_data,
        {
          api_key: Constants::API_KEY,
          idempotency_key: @idempotency_key
        }
      )

      {
        id: created_customer.id,
        name: created_customer.name,
        email: created_customer.email,
        address: created_customer.address.to_h,
        phone: created_customer.phone
      }
    end

    private

    def customer_data
      {
        name: "#{@customer.first_name} #{@customer.last_name}",
        email: @customer.user.email,
        address: residential_address,
        phone: @customer.phone_number
      }
    end

    def residential_address
      return nil unless @customer.residential_address.present?

      {
        city: @customer.residential_address.city,
        country: @customer.residential_address.country,
        line1: @customer.residential_address.line_1,
        line2: @customer.residential_address.line_2,
        postal_code: @customer.residential_address.zip_code,
        state: @customer.residential_address.state
      }
    end
  end
end
