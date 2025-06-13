module Customers
  class Update
    def initialize(customer:, update_customer_data:)
      @customer = customer
      @update_customer_data = update_customer_data
    end

    def call
      @customer.assign_attributes(
        **customer_attributes,
        addresses_attributes:,
        user_attributes: @update_customer_data[:user] || {},
      )

      @customer.save!
    end

    private

    def customer_attributes
      @update_customer_data.except(:user, :addresses)
    end

    def addresses_attributes
      (
        addresses_to_be_created +
        addresses_to_be_updated +
        addresses_to_be_destroyed
      )
    end

    def addresses_to_be_created
      @addresses_to_be_created ||= @update_customer_data.dig(:addresses, :create) || []
    end

    def addresses_to_be_updated
      @addresses_to_be_updated ||= @update_customer_data.dig(:addresses, :update) || []
    end

    def addresses_to_be_destroyed
      @addresses_to_be_destroyed ||= (
        @update_customer_data.dig(:addresses, :delete)&.map do |address_id|
            {  id: address_id, _destroy: true }
        end || []
      )
    end
  end
end
