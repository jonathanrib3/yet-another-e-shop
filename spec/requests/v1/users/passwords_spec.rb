require 'rails_helper'

RSpec.describe "V1::Users::PasswordsController", type: :request do
  include_context "current time and authentication constants stubs"
  let(:parsed_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "POST /users/passwords/reset" do
    context "when requesting a password reset for an existing user with the requested email" do
      let!(:user) { create(:user, id: 1, email: "chocotoneze@mail.com") }
      let(:expected_reset_password_token) { "reset_token_123" }

      before do
        allow(Tokens).to receive(:generate_random_token).and_return(expected_reset_password_token)
      end

      it "returns a created http status code" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(response).to have_http_status(:created)
      end

      it "sends a password reset email" do
        expect {
          post "/v1/users/passwords/reset", params: { email: user.email }
        }.to have_enqueued_mail(UserMailer, :reset_password_email).with(user)
      end

      it "updates user's reset password token" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_token).to eq(expected_reset_password_token)
      end

      it "updates user's reset password sent at timestamp" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_sent_at).to eq(Time.now)
      end

      it "returns a json response with the success message" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(parsed_response).to match(
          {
            message: I18n.t("users.password.reset_request_success"),
            expires_at: user.reload.reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME
          }
        )
      end
    end

    context "when requesting a password reset for an existing user with the requested email" \
      "and the previous token is expired" do
      let!(:user) { create(:user, id: 1, email: "chocotoneze@mail.com", reset_password_sent_at: Time.now - 10.minutes) }
      let(:expected_reset_password_token) { "reset_token_123" }

      before do
        allow(Tokens).to receive(:generate_random_token).and_return(expected_reset_password_token)
      end

      it "returns a created http status code" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(response).to have_http_status(:created)
      end

      it "sends a password reset email" do
        expect {
          post "/v1/users/passwords/reset", params: { email: user.email }
        }.to have_enqueued_mail(UserMailer, :reset_password_email).with(user)
      end

      it "updates user's reset password token" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_token).to eq(expected_reset_password_token)
      end

      it "updates user's reset password sent at timestamp" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_sent_at).to eq(Time.now)
      end

      it "returns a json response with the success message" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(parsed_response).to match(
          {
            message: I18n.t("users.password.reset_request_success"),
            expires_at: user.reload.reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME
          }
        )
      end
    end

    context "when requesting a password reset with an email from an user that doesn't exist" do
      let!(:user) { create(:user, id: 1, email: "chocotoneze@mail.com") }
      let!(:email) { "doesnotexist@mail.com" }
      let(:expected_error) { "" }

      it "returns a not found http status code" do
        post "/v1/users/passwords/reset", params: { email: }
        expect(response).to have_http_status(:not_found)
      end

      it "does not send a password reset email" do
        expect {
          post "/v1/users/passwords/reset", params: { email: }
        }.not_to have_enqueued_mail(UserMailer, :reset_password_email)
      end

      it "does not update user's reset password token" do
        post "/v1/users/passwords/reset", params: { email: }
        expect(user.reload.reset_password_token).to be_nil
      end

      it "does not update user's reset password sent at timestamp" do
        post "/v1/users/passwords/reset", params: { email: }
        expect(user.reload.reset_password_sent_at).to be_nil
      end

      it "returns a json response with an error message" do
        post "/v1/users/passwords/reset", params: { email: }

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.reset_request_email_not_found")
          }
        )
      end
    end

    context "when requesting a password reset more than once before the previous token expires" do
      let(:reset_password_token) { "beautiful_token" }
      let!(:user) do
        create(:user, id: 1, email: "chocotoneze@mail.com", reset_password_sent_at: Time.now - 5.minutes, reset_password_token:)
      end

      it "returns an unprocessable entity http status code" do
        post "/v1/users/passwords/reset", params: { email: user.email }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not send a password reset email" do
        expect {
          post "/v1/users/passwords/reset", params: { email: user.email }
        }.not_to have_enqueued_mail(UserMailer, :reset_password_email)
      end

      it "does not update user's reset password token" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_token).to eq(reset_password_token)
      end

      it "does not update user's reset_password_sent_at timestamp" do
        post "/v1/users/passwords/reset", params: { email: user.email }
        expect(user.reload.reset_password_sent_at).to eq(Time.now - 5.minutes)
      end

      it "returns a json response with an error message" do
        post "/v1/users/passwords/reset", params: { email: user.email }

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.cannot_reset_password_before_due_expiration"),
            expires_at: (user.reset_password_sent_at + User::RESET_PASSWORD_TOKEN_EXPIRATION_TIME).as_json
          }
        )
      end
    end
  end

  describe "DELETE /users/passwords/reset/:token/cancel" do
    context "when cancelling a password reset request with a valid token" do
      let!(:user) do
        create(:user, email: "chocotoneze@mail.com",
                      reset_password_sent_at: Time.now - 5.minutes,
                      reset_password_token: "valid_token")
      end

      before do
        delete "/v1/users/passwords/reset/#{user.reset_password_token}/cancel"
      end

      it "returns a no content http status code" do
        expect(response).to have_http_status(:no_content)
      end

      it "updates the user's reset password token to nil" do
        expect(user.reload.reset_password_token).to be_nil
      end

      it "maintains the user's reset password sent at timestamp" do
        expect(user.reload.reset_password_sent_at).to eq(Time.now - 5.minutes)
      end
    end

    context "when cancelling a password reset request with a token that does not exist" do
      let(:invalid_token) { "invalid_token_123" }

      before do
        delete "/v1/users/passwords/reset/#{invalid_token}/cancel"
      end

      it "returns a not found http status code" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.reset_request_token_not_found")
          }
        )
      end
    end

    context "when cancelling an expired password reset request" do
      let!(:user) do
        create(:user, email: "chocotoneze@mail.com",
                      reset_password_sent_at: Time.now - 10.minutes,
                      reset_password_token: "valid_token")
      end

      before do
        delete "/v1/users/passwords/reset/#{user.reset_password_token}/cancel"
      end

      it "returns an unprocessable entity http status code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the user's reset password token" do
        expect(user.reload.reset_password_token).to eq("valid_token")
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.cannot_cancel_expired_reset_request")
          }
        )
      end
    end
  end

  describe "PATCH /users/passwords" do
    context "when updating the password with a valid token" do
      let!(:user) do
        create(:user, email: "chocotoneze@mail.com",
                      reset_password_sent_at: Time.now,
                      reset_password_token: "valid_token",
                      password: "123Password!")
      end
      let(:params) do
        {
          user: {
            reset_password_token: user.reset_password_token,
            password: "newPassword123!"
          }
        }
      end

      before do
        patch "/v1/users/passwords", params:
      end

      it "returns a no content http status code" do
        expect(response).to have_http_status(:no_content)
      end

      it "updates user's password" do
        expect(user.reload.authenticate("newPassword123!")).to be_truthy
      end

      it "updates reset password token to nil" do
        expect(user.reload.reset_password_token).to be_nil
      end

      it "updates reset password sent at to nil" do
        expect(user.reload.reset_password_sent_at).to be_nil
      end
    end

    context "when updating the password with an expired token" do
      let!(:user) do
        create(:user, email: "chocotoneze@mail.com",
                      reset_password_sent_at: Time.now - 11.minutes,
                      reset_password_token: "valid_token",
                      password: "123Password!")
      end
      let(:params) do
        {
          user: {
            reset_password_token: user.reset_password_token,
            password: "newPassword123!"
          }
        }
      end

      before do
        patch "/v1/users/passwords", params:
      end

      it "returns an unprocessable entity status code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update user's password" do
        expect(user.reload.authenticate("newPassword123!")).to be_falsey
      end

      it "does not update reset password token to nil" do
        expect(user.reload.reset_password_token).to eq("valid_token")
      end

      it "does not update reset password sent at to nil" do
        expect(user.reload.reset_password_sent_at).to eq(Time.now - 11.minutes)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.reset_password_token_expired")
          }
        )
      end
    end

    context "when updating the password with a token that doesn't exist" do
      let!(:user) do
        create(:user, email: "chocotoneze@mail.com",
                      reset_password_sent_at: Time.now + 20.minutes,
                      reset_password_token: "valid_token",
                      password: "123Password!")
      end
      let(:params) do
        {
          user: {
            reset_password_token: "invalid_token",
            password: "newPassword123!"
          }
        }
      end

      before do
        patch "/v1/users/passwords", params:
      end

      it "returns a not found http status code" do
        expect(response).to have_http_status(:not_found)
      end

      it "does not update user's password" do
        expect(user.reload.authenticate("newPassword123!")).to be_falsey
      end

      it "does not update reset password token to nil" do
        expect(user.reload.reset_password_token).to eq("valid_token")
      end

      it "does not update reset password sent at to nil" do
        expect(user.reload.reset_password_sent_at).to eq(Time.now + 20.minutes)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.users.password.reset_request_token_not_found")
          }
        )
      end
    end
  end
end
