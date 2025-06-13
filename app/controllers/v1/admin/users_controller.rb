module V1
  module Admin
    class UsersController < V1::ApplicationController
      include Authenticator
      before_action :authenticate_user!

      def create
        authorize current_user, policy_class: V1::Admin::UsersPolicy
        @admin = ::Users::Create.new(
          email: admin_user_params["email"],
          password: admin_user_params["password"],
          role: :admin
        ).call
        UserMailer.confirmation_email(@admin).deliver_later

        render template: "v1/admin/users/create", status: :created
      end

      def update
        authorize current_user, policy_class: V1::Admin::UsersPolicy

        @admin = User.find(params[:id])
        if @admin.update(admin_user_params.to_h.deep_symbolize_keys)
          render template: "v1/admin/users/update", status: :ok
        else
          @message =  @admin.errors.full_messages.join(", ")
          render "v1/error/error", status: :unprocessable_entity
        end
      end

      private

      def admin_user_params
        params.require(:admin_user).permit(:email, :password)
      end
    end
  end
end
