module V1
    class CustomersController < V1::ApplicationController
      def create
        ActiveRecord::Base.transaction do
          @customer = Customer.new(
            **create_customers_params.to_h.deep_symbolize_keys.except(:user, :addresses),
            user_attributes: create_customers_params["user"],
            addresses_attributes: create_customers_params["addresses"] || {}
          )
          @customer.save!
          UserMailer.confirmation_email(@customer.user).deliver_later
          Stripe::SendCustomerDataJob.perform_async(@customer.id)

          render @customer, status: :created
        end
      end

      private

      def create_customers_params
        params.require(:customer)
          .permit(
            :first_name, :last_name, :phone_number,
            :date_of_birth, :document_number, :document_type,
            user: [ :email, :password ],
            addresses: [ [ :line_1, :line_2, :zip_code, :city, :state, :country, :address_type ] ]
          )
      end
    end
end
