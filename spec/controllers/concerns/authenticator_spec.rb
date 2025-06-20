require 'rails_helper'

class AuthenticateTestsController < TestController
  include ::Authenticator
  before_action :authenticate_user!

  def authenticate_test_current_user
    render json: { current_user: current_user }, status: :ok
  end
end

RSpec.describe ::Authenticator, type: :request do
  include RoutesHelpers
  include_context "current time and authentication constants stubs"

  after do
    reload_routes!
  end

  context 'when authenticating an user with a valid token' do
    let!(:user) { create(:user, id: 1) }
    let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:headers) do
      {
        "Authorization" => "Bearer #{access_token}"
      }
    end

    before do
      draw_test_routes do
        resource :authenticate_test
      end
    end

    it "doesn't return an unauthorized http status code" do
      get authenticate_test_path, headers: headers

      expect(response).not_to have_http_status(:unauthorized)
    end
  end

  context 'when authenticating an user with an invalid token' do
    context "when an access token is from an user that doesn't exist" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, id: 1) }
      let(:invalid_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.dOFM0rFNo1EYBCmvbHCLuMjGtYPikDxFGcsgdn8tAAI"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{invalid_access_token}"
        }
      end

      before do
        draw_test_routes do
          resource :authenticate_test
        end

        get authenticate_test_path, headers: headers
      end

      it "returns an unauthorized http status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when an access token is in a invalid format" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let!(:user) { create(:user, id: 1) }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:exp) { fixed_time.advance(hours: expiry_hours) }
      let(:iss) { jwt_issuer }
      let(:invalid_access_token) do
        "eyJ0eXAiOiJKV1Qinvalidformat"
      end
      let(:headers) do
        {
          "Authorization" => "#{invalid_access_token}"
        }
      end

      before do
        draw_test_routes do
          resource :authenticate_test
        end

        get authenticate_test_path, headers: headers
      end

      it "returns an unauthorized http status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end
  end

  context "when authenticating an user with a token that has a valid user but an invalid jti" do
    let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
    let!(:user) { create(:user, id: 1) }
    let(:invalid_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjVjZjBjYTA5LWM3YWMtNGY5Mi04MTU0LTBiZDFjNWY4OTAyOCIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.nG5zL137NQmtH7dmzowflj6DostVKNVD3AJ3A8JMTIE"
    end

    let(:headers) do
      {
        "Authorization" => "Bearer #{invalid_access_token}"
      }
    end

    before do
      draw_test_routes do
        resource :authenticate_test
      end

      get authenticate_test_path, headers: headers
    end

    it "returns an unauthorized http status code" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns an error message" do
      expect(parsed_response).to match(
        {
          message: I18n.t("errors.messages.invalid_access_token")
        }
      )
    end
  end

  context "when token has a valid jti but an invalid user" do
  end

  context 'when authenticating an user with a blacklisted token' do
    let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
    let!(:user) { create(:user, id: 1) }
    let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
    let(:exp) { fixed_time.advance(hours: expiry_hours) }
    let(:iss) { jwt_issuer }
    let!(:blacklisted_token) do
      create(:black_listed_token, jti_registry:)
    end
    let(:invalid_access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.dOFM0rFNo1EYBCmvbHCLuMjGtYPikDxFGcsgdn8tAAI"
    end
    let(:headers) do
      {
        "Authorization" => "Bearer #{invalid_access_token}"
      }
    end

    before do
      draw_test_routes do
        resource :authenticate_test
      end

      get authenticate_test_path, headers: headers
    end

    it "returns an unauthorized http status code" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns an error message" do
      expect(parsed_response).to match(
        {
          message: I18n.t("errors.messages.invalid_access_token")
        }
      )
    end
  end

  context 'when defining the current user' do
    let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
    let!(:user) { create(:user, id: 1) }
    let!(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
    let(:access_token) do
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
    end
    let(:headers) do
      {
        "Authorization" => "Bearer #{access_token}"
      }
    end
    let(:expected_response) do
      {
        current_user: user.as_json.deep_symbolize_keys
      }
    end

    before do
      draw_test_routes do
        get :authenticate_test_current_user, to: "authenticate_tests#authenticate_test_current_user"
      end
    end

    it "defines the current user based on its token, with the right data" do
      get authenticate_test_current_user_path, headers: headers

      expect(parsed_response).to eq(expected_response)
    end
  end
end
