class UserMailer < ApplicationMailer
  CONFIRMATION_EMAIL_SUBJECT = 'Confirm Your Account – Action Required'.freeze
  DEFAULT_FROM = 'bot@yetanothereshop.com'.freeze
  default from: DEFAULT_FROM
  layout 'mailer'

  def confirmation_email(user)
    @confirmation_link = "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/users/verify/#{user.confirmation_token}"

    mail(to: user.email, subject: CONFIRMATION_EMAIL_SUBJECT)
  end
end
