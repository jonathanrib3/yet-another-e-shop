require "rails_helper"

RSpec.describe Users::Passwords::CreateResetPasswordRequest do
  subject(:create_reset_password_request) { described_class.new(user:) }
  include_context "current time and authentication constants stubs"

  context "when requesting for password reset and the previous reset password token is not expired yet" do
    let(:user) { create(:user, email: "chocotoneze@mail.com", reset_password_sent_at: Time.now) }

    it "raises Errors::Users::Passwords::CannotResetPasswordBeforeDueExpiration with a message" do
      expect {
        create_reset_password_request.call
      }.to raise_error(Errors::Users::Passwords::CannotResetPasswordBeforeDueExpiration) do |error|
        expect(error.message).to eq(I18n.t("errors.users.password.cannot_reset_password_before_due_expiration"))
        expect(error.expires_at).to eq(Time.now + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME)
      end
    end
  end

  context "when requesting for password reset and there are no previous password reset requests" do
    let(:user) { create(:user, email: "chocotoneze@mail.com") }
    let(:expected_reset_password_token) { "some_random_token" }

    before do
      allow(Tokens).to receive(:generate_random_token).and_return(expected_reset_password_token)
    end

    it "updates user reset password token" do
      create_reset_password_request.call
      expect(user.reload.reset_password_token).to eq(expected_reset_password_token)
    end

    it "updates user reset password sent at" do
      create_reset_password_request.call
      expect(user.reload.reset_password_sent_at).to eq(Time.now)
    end

    it "sends reset password email" do
      expect { create_reset_password_request.call }.to have_enqueued_mail(UserMailer, :reset_password_email).with(user)
    end
  end

  context "when requesting for password reset and the previous reset password token is expired" do
    let(:user) { create(:user, email: "chocotoneze@mail.com", reset_password_sent_at: 1.day.ago) }
    let(:expected_reset_password_token) { "some_random_token" }

    before do
      allow(Tokens).to receive(:generate_random_token).and_return(expected_reset_password_token)
    end

    it "updates user reset password token" do
      create_reset_password_request.call
      expect(user.reload.reset_password_token).to eq(expected_reset_password_token)
    end

    it "updates user reset password sent at" do
      create_reset_password_request.call
      expect(user.reload.reset_password_sent_at).to eq(Time.now)
    end

    it "sends reset password email" do
      expect { create_reset_password_request.call }.to have_enqueued_mail(UserMailer, :reset_password_email).with(user)
    end
  end
end
