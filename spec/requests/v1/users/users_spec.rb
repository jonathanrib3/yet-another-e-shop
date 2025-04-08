require 'rails_helper'

RSpec.describe "V1::Users::UsersController", type: :request do
  include_context "current time and authentication constants stubs"

  describe "POST /users/verify/:token" do
    context "when verifying a confirmation token logged in as the user that is the token's owner" do
      let!(:user) { create(:user, :admin, id: 1, confirmed_at: nil) }
      let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      it "returns a no content http status code" do
        post "/v1/users/verify/#{user.confirmation_token}", headers: headers
        expect(response).to have_http_status(:no_content)
      end

      it "updates the user's confirmed at attribute with the right timestamp" do
        post "/v1/users/verify/#{user.confirmation_token}", headers: headers
        expect(user.reload.confirmed_at).to eq(fixed_time)
      end
    end

    context "when verifying a confirmation token not logged in" do
      let!(:user) { create(:user, id: 1, email: "something1@mail.com", confirmed_at: nil) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }

      before do
        post "/v1/users/verify/#{user.confirmation_token}"
      end

      it "returns an unauthorized http status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't update token's owner confirmed_at attribute" do
        expect(user.reload.confirmed_at).to be_nil
      end

      it "returns a json response with the error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when verifying a confirmation token logged in as the user that isn't the token's owner" do
      let!(:users) do
        [ create(:user, id: 1, email: "something1@mail.com", confirmed_at: nil), create(:user, id: 2, email: "something2@mail.com", confirmed_at: nil) ]
      end
      let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user: users.last) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          admin_user: {
            email: "chocotoneze@mail.com",
            password: "AV4l1dP4ssw0rd."
          }
        }
      end
      let(:user_2_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.dOFM0rFNo1EYBCmvbHCLuMjGtYPikDxFGcsgdn8tAAI"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{user_2_access_token}"
        }
      end

      before do
        post "/v1/users/verify/#{users.first.confirmation_token}", headers: headers, params: params
      end

      it "returns a forbidden http status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't update token's owner confirmed_at attribute" do
        expect(users.first.reload.confirmed_at).to be_nil
      end

      it "returns a json response with the error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("pundit.default")
          }
        )
      end
    end

    context "when verifying a confirmation token with an invalid token" do
      let!(:user) { create(:user, id: 1, confirmed_at: nil) }
      let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          admin_user: {
            email: "chocotoneze@mail.com",
            password: "AV4l1dP4ssw0rd."
          }
        }
      end
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      before do
        post "/v1/users/verify/invalid_tokenakdjsn", headers: headers
      end

      it "returns an unprocessable entity http status code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "doesn't update token's owner confirmed_at attribute" do
        expect(user.reload.confirmed_at).to be_nil
      end

      it "returns a json response with the error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_confirmation_token")
          }
        )
      end
    end

    context "when verifying a confirmation token that has been already used" do
      let!(:user) { create(:user, id: 1, confirmed_at: fixed_time.advance(hours: -2)) }
      let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          admin_user: {
            email: "chocotoneze@mail.com",
            password: "AV4l1dP4ssw0rd."
          }
        }
      end
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      before do
        post "/v1/users/verify/#{user.confirmation_token}", headers: headers
      end

      it "returns an unprocessable entity http status code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "doesn't update token's owner confirmed_at attribute" do
        expect(user.reload.confirmed_at).not_to eq(fixed_time)
      end

      it "returns a json response with the error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_confirmation_token")
          }
        )
      end
    end
  end
end
