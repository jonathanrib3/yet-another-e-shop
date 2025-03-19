module Authentication
  class Login
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      if user.authenticate(@password)
        return Authentication::Issuer.new(user:).call
      end

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
