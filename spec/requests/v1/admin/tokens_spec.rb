require 'rails_helper'

RSpec.describe "V1::Admin::TokensController", type: :request do
  include_context "current time and authentication constants stubs"

  context "POST /v1/admin/tokens/black_list" do
    context "when black listing a token unique identifier logged in as an admin user" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:admin) { create(:user, :admin, id: 1) }
      let!(:admin_access_token_jti) {  create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user: admin) }
      let(:user_with_blacklisted_token) { create(:user, id: 2, email: "anotheruser@mail.com") }
      let(:jti_registry_to_be_blacklisted) do
        create(:jti_registry, jti: "6d2704a5-6076-4e01-918c-1123340da08b", user: user_with_blacklisted_token)
      end
      let(:admin_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end

      let(:params) do
        {
          jti: jti_registry_to_be_blacklisted.jti
        }
      end

      let(:headers) do
        {
          "Authorization" => "Bearer #{admin_access_token}"
        }
      end
      let(:expected_response) do
        {
          jti: jti_registry_to_be_blacklisted.jti,
          user_id: user_with_blacklisted_token.id,
          exp: fixed_time.advance(hours: expiry_hours).utc.as_json,
          created_at: fixed_time.utc.as_json,
          updated_at: fixed_time.utc.as_json
        }
      end


      it "returns an ok http status code" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(response).to have_http_status(:success)
      end

      it "blacklists the token" do
        expect do
          post "/v1/admin/tokens/black_list", params: params, headers: headers
        end.to change(BlackListedToken.where(
          jti: jti_registry_to_be_blacklisted.jti
          ), :count
        ).by(1)
      end

      it "returns the blacklisted token info" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(parsed_response).to eq(expected_response)
      end
    end

    context "when black listing a token unique identifier logged in as a non admin user" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, id: 1) }
      let!(:user_access_token_jti) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
      let(:user_with_blacklisted_token) { create(:user, id: 2, email: "anotheruser@mail.com") }
      let(:jti_registry_to_be_blacklisted) do
        create(:jti_registry, jti: "6d2704a5-6076-4e01-918c-1123340da08b", user: user_with_blacklisted_token)
      end
      let(:invalid_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:params) do
        {
          jti: jti_registry_to_be_blacklisted.jti
        }
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{invalid_access_token}"
        }
      end

      it "returns a forbidden http status code" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "does not blacklist the token" do
        expect do
          post "/v1/admin/tokens/black_list", params: params, headers: headers
        end.not_to change(BlackListedToken.where(
          jti: jti_registry_to_be_blacklisted.jti), :count
        )
      end

      it "returns an error message" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(parsed_response).to eq(
          {
            message: I18n.t("pundit.default")
          }
        )
      end
    end

    context "when black listing a token unique identifier not logged in" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          jti: jti_to_be_blacklisted
        }
      end
      let(:jti_to_be_blacklisted) { "6d2704a5-6076-4e01-918c-1123340da08b" }

      it "returns an unauthorized http status code" do
        post "/v1/admin/tokens/black_list", params: params

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not blacklist the token" do
        expect do
          post "/v1/admin/tokens/black_list", params: params, headers: headers
        end.not_to change(BlackListedToken.where(
          jti: jti_to_be_blacklisted), :count
        )
      end

      it "returns an error message" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("errors.messages.invalid_access_token")
        })
      end
    end

    context "when black listing a token unique identifier that has been already black listed" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:admin) { create(:user, :admin, id: 1) }
      let(:user_with_blacklisted_token) { create(:user, id: 2, email: "anotheruser@mail.com") }
      let!(:admin_access_token_jti) {  create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user: admin) }
      let(:blacklisted_token_jti_registry) { create(:jti_registry, jti: "6d2704a5-6076-4e01-918c-1123340da08b", user: user_with_blacklisted_token) }
      let!(:black_listed_token) do
        create(:black_listed_token, jti_registry: blacklisted_token_jti_registry)
      end
      let(:admin_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{admin_access_token}"
        }
      end
      let(:params) do
        {
          jti: blacklisted_token_jti_registry.jti
        }
      end
      let(:expected_response) do
        {
          jti: jti_to_be_blacklisted,
          user_id: user_with_blacklisted_token.id,
          exp: fixed_time.as_json,
          created_at: fixed_time.as_json,
          updated_at: fixed_time.as_json
        }
      end

      it "returns an unprocessable entity response" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/v1/admin/tokens/black_list", params: params, headers: headers

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.services.authentication.revoker.token_already_black_listed")
          }
        )
      end
    end
  end
end
