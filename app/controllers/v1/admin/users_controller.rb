module V1
  module Admin
    class UsersController < V1::ApplicationController
      include Authenticator
      before_action :authenticate_user!

      def create
        authorize :admin_user, :create?

        @admin = ::Users::Create.new(
          email: admin_user_params["email"],
          password: admin_user_params["password"],
          role: :admin
        ).call
        UserMailer.confirmation_email(@admin).deliver_later

        render template: "v1/admin/users/create", status: :created
      end

      private

      def admin_user_params
        params.require(:admin_user).permit(:email, :password)
      end
    end
  end
end
