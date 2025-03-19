class UserPolicy < ApplicationPolicy
  def verify?
    user.id == record.id
  end
end
