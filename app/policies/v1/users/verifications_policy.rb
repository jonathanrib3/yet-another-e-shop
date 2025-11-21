module V1
  module Users
    class VerificationsPolicy < ApplicationPolicy
      def create?
        user.id == record.id
      end
    end
  end
end
