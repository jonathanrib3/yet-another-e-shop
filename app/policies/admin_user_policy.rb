class AdminUserPolicy < ApplicationPolicy
  def create?
    user.admin? && user.confirmed?
  end
end
