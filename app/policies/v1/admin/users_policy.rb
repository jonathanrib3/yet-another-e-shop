module V1
  module Admin
    class UsersPolicy < ApplicationPolicy
      def create?
        admin_and_confirmed?
      end

      def update?
        admin_and_confirmed?
      end

      def black_list?
        admin_and_confirmed?
      end

      private

      def admin_and_confirmed?
        user.admin? && user.confirmed?
      end
    end
  end
end
