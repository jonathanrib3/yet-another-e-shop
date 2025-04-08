require 'rails_helper'

RSpec.describe "V1::Authentications", type: :request do
  include_context "current time and authentication constants stubs"

  describe "POST /auth" do
    context "when authenticating a valid user with his right email and password" do
      let(:user) { create(:user, id: 1) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:expected_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:expected_refresh_token) { "e74eac93371c09d89593d0fd17d1d4258acd4642145ed317437fb6f27b4c777b" }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:params) do
        {
          user:
            {
              email: user.email,
              password: user.password
            }
        }
      end

      before do
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
        allow(Tokens).to receive(:generate_random_token).and_return(expected_refresh_token)
      end

      it "returns an OK Http Status" do
        post "/v1/auth", as: :json, params: params

        expect(response).to have_http_status(:success)
      end

      it "creates a new refresh token" do
        expect { post "/v1/auth", as: :json, params: params }.to change(RefreshToken.where(jti:), :count).by(1)
      end

      it "returns an access and refresh token" do
        post "/v1/auth", as: :json, params: params
        expect(parsed_response).to match(
          {
            access_token: expected_access_token,
            refresh_token: expected_refresh_token
          }
        )
      end
    end

    context "when authenticating with an email that doesn't exist" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          user:
            {
              email: "emailthatdoesntexist@mail.com",
              password: "123123Qwe."
            }
        }
      end

      it "returns an unauthorized Http Status" do
        post "/v1/auth", as: :json, params: params

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new refresh token" do
        expect { post "/v1/auth", as: :json, params: params }.not_to change(RefreshToken, :count)
      end

      it "returns an error message" do
        post "/v1/auth", as: :json, params: params

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_login")
          }
        )
      end
    end

    context "when authenticating with the wrong password" do
      let(:user) { create(:user, id: 1) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          user:
            {
              email: user.email,
              password: "wrongpasswordmyman"
            }
        }
      end

      before do
        post "/v1/auth", as: :json, params:
      end

      it "returns an unauthorized Http Status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_login")
          }
        )
      end
    end
  end

  describe "POST /refresh" do
    context "when getting a new access token through a valid refresh token" do
      let(:user) { create(:user, id: 1) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:expected_new_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:raw_refresh_token) { "e74eac93371c09d89593d0fd17d1d4258acd4642145ed317437fb6f27b4c777b" }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let!(:refresh_token) do
        create(:refresh_token,
          crypted_token: Digest::SHA256.hexdigest(raw_refresh_token + secret),
          exp:,
          jti_registry:,)
      end
      let(:params) do
        {
          refresh_token: raw_refresh_token
        }
      end

      before do
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
        post "/v1/refresh", as: :json, params:
      end

      it "returns an OK Http Status" do
        expect(response).to have_http_status(:success)
      end

      it "returns a new access and the used refresh token" do
        expect(parsed_response).to match(
          {
            access_token: expected_new_access_token,
            refresh_token: raw_refresh_token
          }
        )
      end
    end

    context "when getting a new access token through refresh token that doesn't exist" do
      let(:user) { create(:user, id: 1) }
      let(:fixed_time) { Time.new(1989, 06, 04) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:expected_new_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:raw_refresh_token) { "e74eac93371c09d89593d0fd17d1d4258acd4642145ed317437fb6f27b4c777b" }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let(:params) do
        {
          refresh_token: raw_refresh_token
        }
      end

      before do
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
        post "/v1/refresh", as: :json, params:
      end

      it "returns an Unauthorized Http Status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns a new access and the used refresh token" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_refresh_token")
          }
        )
      end
    end

    context "when authenticating with the wrong password" do
      let(:user) { create(:user, id: 1) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          user:
            {
              email: user.email,
              password: "wrongpasswordmyman"
            }
        }
      end

      before do
        post "/v1/auth", as: :json, params:
      end

      it "returns an unauthorized Http Status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_login")
          }
        )
      end
    end
  end

  describe "POST /logout" do
    context "when logging out from an account, given a valid access token" do
      let(:user) { create(:user, id: 1) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:jti)  { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let!(:refresh_token) do
        create(:refresh_token, exp:, jti_registry:)
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      before do
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti_registry.jti)
      end

      it "returns a no content http status code" do
        post "/v1/logout", as: :json, headers: headers

        expect(response).to have_http_status(:no_content)
      end

      it "blacklist the access token" do
        expect { post "/v1/logout", as: :json, headers: }.to change(BlackListedToken.where(jti:), :count).by(1)
      end

      it "deletes the user existing refresh token" do
        expect { post "/v1/logout", as: :json, headers: }.to change(RefreshToken.where(jti:), :count).from(1).to(0)
      end
    end

    context "when logging out from an account, given an access token that does not belongs to an user" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:user) { create(:user, id: 1) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjE0OSwianRpIjoiOGVhZmQ1ZTItODViNC00NDMyLThmMzktMGY1ZGU2MTAwMWZhIiwiaWF0Ijo2MTI5MzI0MDAsImV4cCI6NjEyOTc1NjAwLCJpc3MiOiJsb2NhbGhvc3QudGVzdCJ9.n6-H9XhWn8V3Br3J64dBvp4Qh7vQWtzTw1f179dc4SY"
      end
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      before do
        allow(Digest::UUID).to receive(:uuid_v4).and_return(jti)
      end

      it "returns an unauthorized http status code" do
        post "/v1/logout", as: :json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't blacklist the access token" do
        expect { post "/v1/logout", as: :json, headers: }.not_to change(BlackListedToken, :count)
      end

      it "doesn't delete the user existing refresh token" do
        expect { post "/v1/logout", as: :json, headers: }.not_to change(RefreshToken, :count)
      end

      it "returns an error message" do
        post "/v1/logout", as: :json, headers: headers

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when logging out from an account, given an invalid access token" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:user) { create(:user, id: 1) }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let(:headers) do
        {
          "Authorization" => "invalid auth format"
        }
      end

      it "returns an unauthorized http status code" do
        post "/v1/logout", as: :json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't blacklist the access token" do
        expect { post "/v1/logout", as: :json, headers: }.not_to change(BlackListedToken, :count)
      end

      it "doesn't delete the user existing refresh token" do
        expect { post "/v1/logout", as: :json, headers: }.not_to change(RefreshToken, :count)
      end

      it "returns an error message" do
        post "/v1/logout", as: :json, headers: headers

        expect(parsed_response).to match(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when logging out from an account with an access token that's black listed" do
      let(:user) { create(:user, id: 1) }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:expected_new_access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:jti_registry) { create(:jti_registry, jti: "8eafd5e2-85b4-4432-8f39-0f5de61001fa", user:) }
      let(:exp) { Time.now.advance(days: refresh_token_expiry_days) }
      let!(:black_listed_token) do
        create(:black_listed_token, jti_registry:)
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{expected_new_access_token}"
        }
      end

      before do
        post "/v1/logout", as: :json, headers:
      end

      it "returns an unprocessable entity Http Status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        expect(parsed_response).to match(
          {
            message: I18n.t("errors.services.authentication.revoker.token_already_black_listed")
          }
        )
      end
    end
  end
end
