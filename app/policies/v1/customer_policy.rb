module V1
  class CustomerPolicy < ApplicationPolicy
    def update?
      can_only_perform_operation_on_itself_unless_admin
    end

    def destroy?
      can_only_perform_operation_on_itself_unless_admin
    end

    def show?
      can_only_perform_operation_on_itself_unless_admin
    end

    private

    def can_only_perform_operation_on_itself_unless_admin
      user.id == record.user_id && user.confirmed? || user.admin?
    end
  end
end
