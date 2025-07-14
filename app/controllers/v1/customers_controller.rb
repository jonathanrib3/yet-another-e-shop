module V1
  class CustomersController < V1::ApplicationController
    include Authenticator

    before_action :authenticate_user!, only: %i[update destroy show]

    def create
      ActiveRecord::Base.transaction do
        @customer = Customer.new(
          **create_customers_params.to_h.deep_symbolize_keys.except(:user, :addresses),
          user_attributes: create_customers_params['user'],
          addresses_attributes: create_customers_params['addresses'] || {}
        )
        @customer.save!
        UserMailer.confirmation_email(@customer.user).deliver_later
        Stripe::SendCustomerDataJob.perform_async(@customer.id)

        render @customer, status: :created
      end
    end

    def update
      @customer = Customer.includes(:addresses, :user).find(params[:id])
      authorize @customer, policy_class: V1::CustomerPolicy
      Customers::Update.new(
        customer: @customer,
        update_customer_data: update_customers_params.to_h.deep_symbolize_keys
      ).call

      render @customer.reload, status: :ok
    end

    def destroy
      @customer = Customer.find(params[:id])
      authorize @customer, policy_class: V1::CustomerPolicy
      @customer.destroy!

      head :no_content
    end

    def show
      @customer = Customer.includes(:addresses, :user).find(params[:id])
      authorize @customer, policy_class: V1::CustomerPolicy

      render @customer, status: :ok
    end

    private

    def create_customers_params
      params.require(:customer)
            .permit(
              :first_name, :last_name, :phone_number,
              :date_of_birth, :document_number, :document_type,
              user: %i[email password],
              addresses: [%i[line_1 line_2 zip_code city state country address_type]]
            )
    end

    def update_customers_params
      params.require(:customer)
            .permit(
              :first_name, :last_name, :phone_number,
              :date_of_birth, :document_number, :document_type,
              user: %i[email password],
              addresses: {
                create: %i[line_1 line_2 zip_code city state country address_type],
                update: %i[id line_1 line_2 zip_code city state country address_type],
                delete: []
              }
            )
    end
  end
end
