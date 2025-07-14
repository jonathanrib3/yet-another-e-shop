module Authentication
  class Login
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      return Authentication::Issuer.new(user:).call if user.authenticate(@password)

      raise Errors::Authentication::Login::InvalidEmailOrPassword
    end

    private

    def user
      @user ||= User.find_by!(email: @email)
    rescue ActiveRecord::RecordNotFound
      raise Errors::Authentication::Login::InvalidEmailOrPassword
    end
  end
end
