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
end
