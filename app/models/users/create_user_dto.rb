module Users
  class CreateUserDTO
    include ActiveModel::Model

    validates :email, :password, :role, presence: true
  end
end
