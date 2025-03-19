module V1
  module Admin
    class AdminController < ApplicationController
      def create
        admin_user = User.new(admin_user_params)
        if admin_user.save
        render json: { message: "Admin user created successfully", admin_user: admin_user }, status: :created
        else
        render json: { errors: admin_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def admin_user_params
        params.require(:admin_user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
