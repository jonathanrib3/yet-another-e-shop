module Users
  class Create
    def initialize(password:, email:, role: :customer)
      @password = password
      @email = email
      @role = role
      validate_attributes_presence
    end

    def call
      confirmation_token = Tokens.generate_random_token

      User.create!(
        confirmation_token:,
        password: @password,
        email: @email,
        role: @role,
        confirmation_sent_at: Time.now())
    end

    def validate_attributes_presence
      raise Errors::Users::CreateUser::InvalidAttributes if @password.blank? || @email.blank?
    end
  end
end
