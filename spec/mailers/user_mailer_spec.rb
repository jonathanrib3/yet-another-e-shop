require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "confirmation_email" do
    let(:user) { create(:user, email: "anothertest@mail.com") }
    let(:mail) { UserMailer.confirmation_email(user) }
    let(:confirmation_link_url) { "http://localhost:3000/users/verify/#{user.confirmation_token}" }

    before do
      stub_const("ENV", ENV.to_h.merge("APP_URL" => "http://localhost:3000"))
    end

    it "renders the headers" do
      expect(mail.subject).to eq(UserMailer::CONFIRMATION_EMAIL_SUBJECT)
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ UserMailer::DEFAULT_FROM ])
    end

    it "renders the body, containing the confirmation link" do
      expect(mail.body.encoded).to include(confirmation_link_url)
    end
  end

  describe "reset_password_email" do
    let(:frontend_base_url) { "http://localhost:3002" }
    let(:user) { create(:user, email: "chocotoneze@mail.com") }
    let(:mail) { UserMailer.reset_password_email(user) }
    let(:expected_reset_password_link_url) { "#{frontend_base_url}/users/password/reset/#{user.reset_password_token}" }
    let(:expected_reset_password_cancellation_link_url) { "#{frontend_base_url}/users/password/reset/cancel?token=#{user.reset_password_token}" }

    before do
      stub_const("ENV", ENV.to_h.merge("FRONTEND_BASE_URL" => frontend_base_url))
    end

    it "renders the correct headers" do
      expect(mail.subject).to eq(UserMailer::RESET_PASSWORD_EMAIL_SUBJECT)
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ UserMailer::DEFAULT_FROM ])
    end

    it "renders the body, containing the reset password link" do
      expect(mail.body.encoded).to include(expected_reset_password_link_url)
    end

    it "renders the body, containing the reset password cancellation link" do
      expect(mail.body.encoded).to include(expected_reset_password_cancellation_link_url)
    end
  end
end
