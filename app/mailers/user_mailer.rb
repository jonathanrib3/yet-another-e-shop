class UserMailer < ApplicationMailer
  CONFIRMATION_EMAIL_SUBJECT = 'Confirm Your Account – Action Required'.freeze
  RESET_PASSWORD_EMAIL_SUBJECT = "Reset Your Password – Action Required".freeze
  DEFAULT_FROM = 'bot@yetanothereshop.com'.freeze
  default from: DEFAULT_FROM
  layout 'mailer'.freeze

  def confirmation_email(user)
    @confirmation_link = "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/users/verify/#{user.confirmation_token}"

    mail(to: user.email, subject: CONFIRMATION_EMAIL_SUBJECT)
  end

  def reset_password_email(user)
    @reset_password_link = "#{ENV["FRONTEND_BASE_URL"]}" \
    "/users/password/reset/#{user.reset_password_token}"
    @reset_password_cancellation_link = "#{ENV["FRONTEND_BASE_URL"]}" \
    "/users/password/reset/cancel?token=#{user.reset_password_token}"

    mail(to: user.email, subject: RESET_PASSWORD_EMAIL_SUBJECT)
  end
end
