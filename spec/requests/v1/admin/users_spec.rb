require 'rails_helper'

RSpec.describe "V1::Admin::UsersController", type: :request do
  include_context "current time and authentication constants stubs"

  describe "POST /admin" do
    context "when creating a new admin user, logged in as an admin" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, :admin, id: 1) }
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

      it "returns a 201 status code" do
        post "/v1/admin/users", params: params, headers: headers

        expect(response).to have_http_status(:created)
      end

      it "creates a new admin user with the correct data" do
        expect do
          post "/v1/admin/users", params: params, headers: headers
        end.to change(User.where({ email: params[:admin_user][:email], role: :admin  }), :count).by(1)
      end

      it "sends a confirmation email to the created admin user" do
        expect do
          post "/v1/admin/users", params: params, headers: headers
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(kind_of?(User))
      end

      it "returns created admin data" do
        post "/v1/admin/users", params: params, headers: headers

        expect(parsed_response).to match(
          {
            email: params[:admin_user][:email],
            password: params[:admin_user][:password],
            role: "admin",
            confirmed_at: nil
          }
        )
      end
    end

    context "when creating a new admin user, logged in as a non-admin" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, id: 1) }
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

      it "returns a forbidden HTTP status code" do
        post "/v1/admin/users", params: params, headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create a new admin user" do
        expect do
          post "/v1/admin/users", params: params, headers: headers
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/admin/users", params: params, headers: headers

        expect(parsed_response).to match(
          {
            message: I18n.t("pundit.default")
          }
        )
      end
    end

    context "when creating a new admin user, not logged" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, id: 1) }
      let(:params) do
        {
          admin_user: {
            email: "chocotoneze@mail.com",
            password: "AV4l1dP4ssw0rd."
          }
        }
      end

      it "returns an unauthorized HTTP status code" do
        post "/v1/admin/users", params: params, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new admin user" do
        expect do
          post "/v1/admin/users", params: params, headers: headers
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/admin/users", params: params, headers: headers

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when creating a new admin user, logged in as an admin, but with invalid params" do
      context "when email has an invalid format" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let!(:user) { create(:user, :admin, id: 1) }
        let(:params) do
          {
            admin_user: {
              email: "chocotoneze@123..com",
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
        let(:expected_errors) do
          "Email #{I18n.t("errors.attributes.email.invalid")}"
        end

        it "returns an unprocessable entity status code" do
          post "/v1/admin/users", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "doesn't create a new admin user with the correct data" do
          expect do
            post "/v1/admin/users", params: params, headers: headers
          end.not_to change(User, :count)
        end

        it "returns created admin data" do
          post "/v1/admin/users", params: params, headers: headers

          expect(parsed_response).to match(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when password has an invalid format" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let!(:user) { create(:user, :admin, id: 1) }
        let(:params) do
          {
            admin_user: {
              email: "chocotoneze@123something.com",
              password: "AnInvalidPassword."
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
        let(:expected_errors) do
          "Password #{I18n.t("errors.attributes.password.invalid")}"
        end

        it "returns an unprocessable entity status code" do
          post "/v1/admin/users", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "doesn't create a new admin user with the correct data" do
          expect do
            post "/v1/admin/users", params: params, headers: headers
          end.not_to change(User, :count)
        end

        it "returns created admin data" do
          post "/v1/admin/users", params: params, headers: headers

          expect(parsed_response).to match(
            {
              message: expected_errors
            }
          )
        end
      end
    end
  end
end
