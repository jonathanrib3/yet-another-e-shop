require 'rails_helper'

RSpec.describe "V1::CustomersController", type: :request do
  include_context "current time and authentication constants stubs"

  context "SHOW /v1/customers/:id" do
    context "when a logged in customer retrieves its own data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: user.email
            },
            first_name: customer.first_name,
            last_name: customer.last_name,
            phone_number: customer.phone_number,
            document_number: customer.document_number,
            document_type: customer.document_type,
            date_of_birth: customer.date_of_birth.strftime("%Y-%m-%d"),
            addresses: customer.addresses.as_json
          }
        }
      end

      it "returns an ok http status code" do
        get "/v1/customers/#{customer.id}", headers: headers

        expect(response).to have_http_status(:ok)
      end

      it "returns the customer data" do
        get "/v1/customers/#{customer.id}", headers: headers

        expect(parsed_response[:customer]).to include(expected_partial_response[:customer])
      end
    end

    context "when a logged in customer retrieves another customer's data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:logged_user) { create(:user, id: 1) }
      let!(:logged_user_jti_registry) { create(:jti_registry, jti:, user: logged_user) }
      let!(:customer_to_be_retrieved) { create(:customer) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      it "returns a forbidden http status code" do
        get "/v1/customers/#{customer_to_be_retrieved.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message" do
        get "/v1/customers/#{customer_to_be_retrieved.id}", headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("pundit.default")
        })
      end
    end

    context "when a logged in, unconfirmed user retrieves its own data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1, confirmed_at: nil) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: user.email
            },
            first_name: customer.first_name,
            last_name: customer.last_name,
            phone_number: customer.phone_number,
            document_number: customer.document_number,
            document_type: customer.document_type,
            date_of_birth: customer.date_of_birth.strftime("%Y-%m-%d"),
            addresses: customer.addresses.as_json
          }
        }
      end

      it "returns a forbidden http status code" do
        get "/v1/customers/#{customer.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message" do
        get "/v1/customers/#{customer.id}", headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("pundit.default")
        })
      end
    end

    context "when a not logged in customer tries to retrieve customer's data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }

      it "returns an unauthorized http status code" do
        get "/v1/customers/#{customer.id}"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        get "/v1/customers/#{customer.id}"

        expect(parsed_response).to eq({
          message: I18n.t("errors.messages.invalid_access_token")
        })
      end
    end

    context "when a logged in customer tries to retrieve a non-existent customer's data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:invalid_customer_id) { 'invalid_id' }

      it "returns a not found http status" do
        get "/v1/customers/#{invalid_customer_id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        get "/v1/customers/#{invalid_customer_id}", headers: headers

        expect(parsed_response).to eq({
          message: "Couldn't find Customer with 'id'=#{invalid_customer_id}"
        })
      end
    end
  end

  context "POST /v1/customers" do
    context "when registering a customer with cpf as the document number, using valid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com",
              password: "Valid_password123"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "123.456.789-01",
            document_type: "cpf",
            date_of_birth: "1990-01-01",
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              },
              {
                line_1: "some shipping address 2",
                line_2: "shipping address 2 number",
                zip_code: "111111",
                city: "Curitiba",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "123.456.789-01",
            document_type: "cpf",
            date_of_birth: "1990-01-01",
            addresses: params[:customer][:addresses].map do |address|
              {
                line_1: address[:line_1],
                line_2: address[:line_2],
                zip_code: address[:zip_code],
                city: address[:city],
                state: address[:state],
                country: address[:country],
                address_type: address[:address_type].to_s
              }
            end
          }
        }
      end
      let(:parsed_response_addresses) do
        parsed_response[:customer][:addresses].map { |address| address.except(:id, :customer_id, :created_at, :updated_at) }
      end

      it "returns a created http status code" do
        post "/v1/customers", params: params

        expect(response).to have_http_status(:created)
      end

      it "creates a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Customer.where(document_number: params[:customer][:document_number]), :count
        ).by(1)
      end

      it "creates a new user" do
        expect do
          post "/v1/customers/", params: params
        end.to change(User.where(email: params[:customer][:user][:email]), :count
        ).by(1)
      end

      it "creates all the requested addresses" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Address, :count).by(4)
      end

      it "sends a confirmation email to the created user" do
        expect do
          post "/v1/customers/", params: params
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with kind_of?(User)
      end

      it "sends customer data to stripe" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Stripe::SendCustomerDataJob.jobs, :size).by(1)
      end

      it "returns created customer info" do
        post "/v1/customers/", params: params

        expect(
          parsed_response[:customer].except(:addresses)
        ).to include(expected_partial_response[:customer].except(:addresses))
      end

      it "returns created customer addresses info" do
        post "/v1/customers/", params: params

        expect(parsed_response_addresses).to match_array(expected_partial_response[:customer][:addresses])
      end
    end

    context "when registering a customer with rg as the document number, using valid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com",
              password: "Valid_password123"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "62.318.157-53",
            document_type: "rg",
            date_of_birth: "1990-01-01",
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              },
              {
                line_1: "some shipping address 2",
                line_2: "shipping address 2 number",
                zip_code: "111111",
                city: "Curitiba",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "62.318.157-53",
            document_type: "rg",
            date_of_birth: "1990-01-01"
          }
        }
      end

      it "returns a created http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:created)
      end

      it "creates a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Customer.where(document_number: params[:customer][:document_number]), :count
        ).by(1)
      end

      it "creates a new user" do
        expect do
          post "/v1/customers/", params: params
        end.to change(User.where(email: params[:customer][:user][:email]), :count
        ).by(1)
      end

      it "sends customer data to stripe" do
        expect do
          post "/v1/customers", params: params
        end.to change(Stripe::SendCustomerDataJob.jobs, :size).by(1)
      end

      it "returns created customer info" do
        post "/v1/customers/", params: params

        expect(parsed_response[:customer]).to include(expected_partial_response[:customer])
      end
    end

    context "when registering a customer with passport as the document number, using valid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com",
              password: "Valid_password123"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "CF595654",
            document_type: "passport",
            date_of_birth: "1990-01-01",
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              },
              {
                line_1: "some shipping address 2",
                line_2: "shipping address 2 number",
                zip_code: "111111",
                city: "Curitiba",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: "valid_email123@mail.com"
            },
            first_name: "Benjamin",
            last_name: "Tennyson",
            phone_number: "+1234567890",
            document_number: "CF595654",
            document_type: "passport",
            date_of_birth: "1990-01-01"
          }
        }
      end

      it "returns a created http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:created)
      end

      it "creates a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Customer.where(document_number: params[:customer][:document_number]), :count
        ).by(1)
      end

      it "creates a new user" do
        expect do
          post "/v1/customers/", params: params
        end.to change(User.where(email: params[:customer][:user][:email]), :count
        ).by(1)
      end

      it "sends customer data to stripe" do
        expect do
          post "/v1/customers/", params: params
        end.to change(Stripe::SendCustomerDataJob.jobs, :size).by(1)
      end

      it "returns created customer info" do
        post "/v1/customers/", params: params

        expect(parsed_response[:customer]).to include(expected_partial_response[:customer])
      end
    end

    context "when registering a customer with user invalid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "invalidemail@-321.com",
              password: "invalid_password123"
            },
            first_name: "oh well",
            last_name: "oh well",
            phone_number: "119919089",
            document_number: "123.456.901-89",
            document_type: "cpf",
            date_of_birth: "1989-01-01",
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "User email #{I18n.t("errors.attributes.email.invalid")}, " \
        "User password #{I18n.t("errors.attributes.password.invalid")}"
      end

      it "returns an unprocessable entity http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(Customer, :count)
      end

      it "does not create a new user" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/customers/", params: params

        expect(parsed_response).to eq(
          {
            message: expected_errors
          }
        )
      end
    end

    context "when registering a customer with cpf as the document number, using customer invalid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "validemail@231test.com",
              password: "Valid_password123"
            },
            first_name: nil,
            last_name: nil,
            phone_number: nil,
            document_number: "123.4569-01",
            document_type: "cpf",
            date_of_birth: nil,
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "First name #{I18n.t("errors.messages.blank")}, Last name #{I18n.t("errors.messages.blank")}, " \
        "Phone number #{I18n.t("errors.messages.blank")}, " \
        "Date of birth #{I18n.t("errors.messages.blank")}, " \
        "Document number #{I18n.t("errors.attributes.document_number.invalid_cpf_format")}" \
      end

      it "returns an unprocessable entity http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(Customer, :count)
      end

      it "does not create a new user" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/customers/", params: params

        expect(parsed_response).to eq(
          {
            message: expected_errors
          }
        )
      end
    end

    context "when registering a customer with rg as the document number, using customer invalid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "validemail@231test.com",
              password: "Valid_password123"
            },
            first_name: nil,
            last_name: nil,
            phone_number: nil,
            document_number: "23.46.91-89",
            document_type: "rg",
            date_of_birth: nil,
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "First name #{I18n.t("errors.messages.blank")}, Last name #{I18n.t("errors.messages.blank")}, " \
        "Phone number #{I18n.t("errors.messages.blank")}, " \
        "Date of birth #{I18n.t("errors.messages.blank")}, " \
        "Document number #{I18n.t("errors.attributes.document_number.invalid_rg_format")}" \
      end

      it "returns an unprocessable entity http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(Customer, :count)
      end

      it "does not create a new user" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/customers/", params: params

        expect(parsed_response).to eq(
          {
            message: expected_errors
          }
        )
      end
    end

    context "when registering a customer with passport as the document number, using customer invalid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "validemail@231test.com",
              password: "Valid_password123"
            },
            first_name: nil,
            last_name: nil,
            phone_number: nil,
            document_number: "23.46.91-89",
            document_type: "passport",
            date_of_birth: nil,
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some billing address 2",
                line_2: "billing address 2 number",
                zip_code: "111111",
                city: "Xique-Xique",
                state: "Bahia",
                country: "Brazil",
                address_type: :billing
              },
              {
                line_1: "some shipping address",
                line_2: "shipping address number",
                zip_code: "111111",
                city: "Guarapuava",
                state: "Paraná",
                country: "Brazil",
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "First name #{I18n.t("errors.messages.blank")}, Last name #{I18n.t("errors.messages.blank")}, " \
        "Phone number #{I18n.t("errors.messages.blank")}, " \
        "Date of birth #{I18n.t("errors.messages.blank")}, " \
        "Document number #{I18n.t("errors.attributes.document_number.invalid_passport_format")}" \
      end

      it "returns an unprocessable entity http status code" do
        post "/v1/customers/", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new customer" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(Customer, :count)
      end

      it "does not create a new user" do
        expect do
          post "/v1/customers/", params: params
        end.not_to change(User, :count)
      end

      it "returns an error message" do
        post "/v1/customers/", params: params

        expect(parsed_response).to eq(
          {
            message: expected_errors
          }
        )
      end
    end

    context "when registering a customer with invalid address data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:params) do
        {
          customer: {
            user: {
              email: "validemail@321mail.com",
              password: "Valid_password123"
            },
            first_name: "oh well",
            last_name: "oh well",
            phone_number: "119919089",
            document_number: "123.456.901-89",
            document_type: "cpf",
            date_of_birth: "1989-01-01",
            addresses: [
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: "some residential address",
                line_2: "residential address number",
                zip_code: "111111",
                city: "São Paulo",
                state: "São Paulo",
                country: "Brazil",
                address_type: :residential
              },
              {
                line_1: nil,
                line_2: nil,
                zip_code: nil,
                city: nil,
                state: nil,
                country: nil,
                address_type: :billing
              },
              {
                line_1: nil,
                line_2: nil,
                zip_code: nil,
                city: nil,
                state: nil,
                country: nil,
                address_type: :billing
              },
              {
                line_1: nil,
                line_2: nil,
                zip_code: nil,
                city: nil,
                state: nil,
                country: nil,
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_residential_address")}, " \
        "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_billing_address")}, " \
        "Addresses line 1 #{I18n.t("errors.messages.blank")}, " \
        "Addresses zip code #{I18n.t("errors.messages.blank")}, " \
        "Addresses city #{I18n.t("errors.messages.blank")}, " \
        "Addresses state #{I18n.t("errors.messages.blank")}, " \
        "Addresses country #{I18n.t("errors.messages.blank")}"
      end

      it "returns an unprocessable entity response" do
        post "/v1/customers", params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new user" do
        expect do
          post "/v1/customers", params: params
        end.not_to change(User, :count)
      end

      it "does not create a new customer" do
        expect do
          post "/v1/customers", params: params
        end.not_to change(Customer, :count)
      end

      it "does not create a new address" do
        expect do
          post "/v1/customers", params: params
        end.not_to change(Address, :count)
      end

      it "returns an error message" do
        post "/v1/customers", params: params
        expect(parsed_response).to eq(
          {
            message: expected_errors
          }
        )
      end
    end
  end

  context "PATCH /v1/customers/:id" do
    context "when a logged in customer updates itself with valid data" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) do
        create(:customer, user:) do |customer|
          customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
        end
      end
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:params) do
        {
          customer: {
            user: {
              email: "newValid_email123@mail.com",
              password: "newValid_password123"
            },
            first_name: "newName",
            last_name: "newLastName",
            phone_number: "+0987654321",
            document_number: "456.789.123-49",
            document_type: "cpf",
            date_of_birth: "1987-08-08",
            addresses: {
              update: [
                {
                  id: customer.shipping_addresses.first.id,
                  line_1: "an updated residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                }
              ],
              create: [
                {
                  line_1: "a new billing address",
                  line_2: "a new billing address number",
                  zip_code: "111111",
                  city: "Manaus",
                  state: "Amazonas",
                  country: "Brazil",
                  address_type: :billing
                }
              ],
              delete: [ customer.shipping_addresses.last.id ]
            }
          }
        }
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:new_customer_data) do
        {
          first_name: params[:customer][:first_name],
          last_name: params[:customer][:last_name],
          phone_number: params[:customer][:phone_number],
          document_number: params[:customer][:document_number],
          document_type: params[:customer][:document_type],
          date_of_birth: params[:customer][:date_of_birth]
        }
      end
      let(:updated_address_data) do
        {
          line_1: params[:customer][:addresses][:update].first[:line_1],
          line_2: params[:customer][:addresses][:update].first[:line_2],
          zip_code: params[:customer][:addresses][:update].first[:zip_code],
          city: params[:customer][:addresses][:update].first[:city],
          state: params[:customer][:addresses][:update].first[:state],
          country: params[:customer][:addresses][:update].first[:country],
          address_type: params[:customer][:addresses][:update].first[:address_type].to_s
        }
      end
      let(:expected_partial_response) do
        {
          customer: {
            user: {
              email: params[:customer][:user][:email]
            },
            first_name: params[:customer][:first_name],
            last_name: params[:customer][:last_name],
            phone_number: params[:customer][:phone_number],
            document_number: params[:customer][:document_number],
            document_type: params[:customer][:document_type],
            date_of_birth: params[:customer][:date_of_birth]
          }
        }
      end
      let(:expected_addresses) do
        customer.reload.addresses.map { |address| address.as_json.deep_symbolize_keys }
      end

      it "returns an ok http status code" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(response).to have_http_status(:success)
      end

      it "updates customers data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.as_json.deep_symbolize_keys).to include(new_customer_data)
      end

      it "updates users data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_truthy
        expect(customer.reload.user.email).to eq(params[:customer][:user][:email])
      end

      it "updates the requested address data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.residential_address.as_json.deep_symbolize_keys).to include(updated_address_data)
      end

      it "creates the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.to change(Address.where(**params[:customer][:addresses][:create].first), :count).from(0).to(1)
      end

      it "deletes the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.to change(Address.where(id: customer.shipping_addresses.last.id), :count).from(1).to(0)
      end

      it "returns updated customer info" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(parsed_response[:customer]).to include(expected_partial_response[:customer])
        expect(parsed_response[:customer][:addresses]).to match_array(expected_addresses)
      end
    end

    context "when a logged in customer updates itself with invalid data" do
      context "when user data is invalid" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newinalid_email123@13123/.com",
                password: "newinalid_password123"
              },
              first_name: "newName",
              last_name: "newLastName",
              phone_number: "+0987654321",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1987-08-08",
              addresses: {
                update: [
                  {
                    id: customer.residential_address.id,
                    line_1: "an updated residential address",
                    line_2: "residential address number",
                    zip_code: "111111",
                    city: "São Paulo",
                    state: "São Paulo",
                    country: "Brazil",
                    address_type: :residential
                  }
                ],
                create: [
                  {
                    line_1: "a new billing address",
                    line_2: "a new billing address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :shipping
                  }
                ],
                delete: [ customer.billing_address.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:expected_errors) do
          "User email #{I18n.t("errors.attributes.email.invalid")}, User password #{I18n.t("errors.attributes.password.invalid")}"
        end

        it "returns an unprocessable status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when customer data is invalid" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: nil,
              last_name: nil,
              phone_number: nil,
              document_number: "456.79.123-49",
              document_type: "fpc",
              date_of_birth: nil,
              addresses: {
                update: [
                  {
                    id: customer.residential_address.id,
                    line_1: "an updated residential address",
                    line_2: "residential address number",
                    zip_code: "111111",
                    city: "São Paulo",
                    state: "São Paulo",
                    country: "Brazil",
                    address_type: :residential
                  }
                ],
                create: [
                  {
                    line_1: "a new shipping address",
                    line_2: "a new shipping address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :shipping
                  }
                ],
                delete: [ customer.billing_address.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:new_customer_data) do
          {
            first_name: params[:customer][:first_name],
            last_name: params[:customer][:last_name],
            phone_number: params[:customer][:phone_number],
            document_number: params[:customer][:document_number],
            document_type: params[:customer][:document_type],
            date_of_birth: params[:customer][:date_of_birth]
          }
        end
        let(:updated_address_data) do
          {
            line_1: params[:customer][:addresses][:update].first[:line_1],
            line_2: params[:customer][:addresses][:update].first[:line_2],
            zip_code: params[:customer][:addresses][:update].first[:zip_code],
            city: params[:customer][:addresses][:update].first[:city],
            state: params[:customer][:addresses][:update].first[:state],
            country: params[:customer][:addresses][:update].first[:country],
            address_type: params[:customer][:addresses][:update].first[:address_type].to_s
          }
        end
        let(:expected_partial_response) do
          {
            customer: {
              user: {
                email: params[:customer][:user][:email]
              },
              first_name: params[:customer][:first_name],
              last_name: params[:customer][:last_name],
              phone_number: params[:customer][:phone_number],
              document_number: params[:customer][:document_number],
              document_type: params[:customer][:document_type],
              date_of_birth: params[:customer][:date_of_birth]
            }
          }
        end
        let(:expected_addresses) do
          customer.reload.addresses.map { |address| address.as_json.deep_symbolize_keys }
        end
        let(:expected_errors) do
          "Document type #{I18n.t("errors.messages.inclusion")}, " \
          "First name #{I18n.t("errors.messages.blank")}, Last name #{I18n.t("errors.messages.blank")}, " \
          "Phone number #{I18n.t("errors.messages.blank")}, Date of birth #{I18n.t("errors.messages.blank")}, " \
          "Document type #{I18n.t("errors.messages.invalid")}"
        end

        it "returns an unprocessable status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when trying to update addresses to contain one more residential address" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: "last name",
              last_name: "first name",
              phone_number: "+1234567890",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1990-01-01",
              addresses: {
                create: [
                  {
                    line_1: "a new residential address",
                    line_2: "residential address number",
                    zip_code: "111111",
                    city: "São Paulo",
                    state: "São Paulo",
                    country: "Brazil",
                    address_type: :residential
                  }
                ],
                update: [
                  {
                    id: customer.billing_address.id,
                    line_1: "a new billing address",
                    line_2: "a new billing address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :billing
                  }
                ],
                delete: [ customer.shipping_addresses.first.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:expected_errors) do
          "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_residential_address")}"
        end

        it "returns an unprocessable status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when trying to update addresses to contain one more billing address" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: "last name",
              last_name: "first name",
              phone_number: "+1234567890",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1990-01-01",
              addresses: {
                create: [
                  {
                    line_1: "a new billing address",
                    line_2: "a new billing address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :billing
                  }
                ],
                update: [
                  id: customer.residential_address.id,
                  line_1: "a new residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                ],
                delete: [ customer.shipping_addresses.first.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:expected_errors) do
          "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_billing_address")}"
        end

        it "returns an unprocessable status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when trying to create or update addresses with invalid data" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: "last name",
              last_name: "first name",
              phone_number: "+1234567890",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1990-01-01",
              addresses: {
                create: [
                  {
                    line_1: nil,
                    line_2: nil,
                    zip_code: nil,
                    city: nil,
                    state: nil,
                    country: nil,
                    address_type: :shipping
                  },
                  {
                    line_1: "nil",
                    line_2: "nil",
                    zip_code: "nil",
                    city: "nil",
                    state: "nil",
                    country: "nil",
                    address_type: :invalid_type
                  }
                ],
                update: [
                  id: customer.residential_address.id,
                  line_1: nil,
                  line_2: nil,
                  zip_code: nil,
                  city: nil,
                  state: nil,
                  country: nil,
                  address_type: :residential
                ],
                delete: [ customer.shipping_addresses.first.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:expected_errors) do
          "Addresses line 1 #{I18n.t("errors.messages.blank")}, Addresses zip code #{I18n.t("errors.messages.blank")}, " \
          "Addresses city #{I18n.t("errors.messages.blank")}, Addresses state #{I18n.t("errors.messages.blank")}, " \
          "Addresses country #{I18n.t("errors.messages.blank")}, Addresses address type #{I18n.t("errors.messages.inclusion")}"
        end

        it "returns an unprocessable status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when trying to update an address that doesn't exist" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: "last name",
              last_name: "first name",
              phone_number: "+1234567890",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1990-01-01",
              addresses: {
                create: [
                  {
                    line_1: "a new billing address",
                    line_2: "a new billing address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :billing
                  }
                ],
                update: [
                  id: "non-existing-id",
                  line_1: "a new residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                ],
                delete: [ customer.shipping_addresses.first.id ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:new_customer_data) do
          {
            first_name: params[:customer][:first_name],
            last_name: params[:customer][:last_name],
            phone_number: params[:customer][:phone_number],
            document_number: params[:customer][:document_number],
            document_type: params[:customer][:document_type],
            date_of_birth: params[:customer][:date_of_birth]
          }
        end
        let(:updated_address_data) do
          {
            line_1: params[:customer][:addresses][:update].first[:line_1],
            line_2: params[:customer][:addresses][:update].first[:line_2],
            zip_code: params[:customer][:addresses][:update].first[:zip_code],
            city: params[:customer][:addresses][:update].first[:city],
            state: params[:customer][:addresses][:update].first[:state],
            country: params[:customer][:addresses][:update].first[:country],
            address_type: params[:customer][:addresses][:update].first[:address_type].to_s
          }
        end
        let(:expected_partial_response) do
          {
            customer: {
              user: {
                email: params[:customer][:user][:email]
              },
              first_name: params[:customer][:first_name],
              last_name: params[:customer][:last_name],
              phone_number: params[:customer][:phone_number],
              document_number: params[:customer][:document_number],
              document_type: params[:customer][:document_type],
              date_of_birth: params[:customer][:date_of_birth]
            }
          }
        end
        let(:expected_addresses) do
          customer.reload.addresses.map { |address| address.as_json.deep_symbolize_keys }
        end
        let(:expected_errors) do
          "Couldn't find Address with ID=non-existing-id for Customer with ID=#{customer.id}"
        end

        it "returns a not found status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:not_found)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end

      context "when trying to delete an address that doesn't exist" do
        let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
        let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
        let(:user) { create(:user, id: 1) }
        let!(:jti_registry) { create(:jti_registry, jti:, user:) }
        let(:customer) { create(:customer, :with_addresses, user:) }
        let(:access_token) do
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
        end
        let(:params) do
          {
            customer: {
              user: {
                email: "newValid_email123@mail.com",
                password: "newValid_password123"
              },
              first_name: "last name",
              last_name: "first name",
              phone_number: "+1234567890",
              document_number: "456.789.123-49",
              document_type: "cpf",
              date_of_birth: "1990-01-01",
              addresses: {
                create: [
                  {
                    line_1: "a new billing address",
                    line_2: "a new billing address number",
                    zip_code: "111111",
                    city: "Manaus",
                    state: "Amazonas",
                    country: "Brazil",
                    address_type: :billing
                  }
                ],
                update: [
                  id: customer.residential_address.id,
                  line_1: "a new residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                ],
                delete: [ "invalid-id" ]
              }
            }
          }
        end
        let(:headers) do
          {
            "Authorization" => "Bearer #{access_token}"
          }
        end
        let(:expected_errors) do
          "Couldn't find Address with ID=invalid-id for Customer with ID=#{customer.id}"
        end

        it "returns a not found status http status code" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(response).to have_http_status(:not_found)
        end

        it "does not update customers data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
        end

        it "does not update users data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
          expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
        end

        it "does not update the requested address data" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(
            customer.reload.residential_address.line_1
          ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
        end

        it "does not create the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
        end

        it "does not delete the requested address data" do
          expect do
            patch "/v1/customers/#{customer.id}", params: params, headers: headers
          end.not_to change(Address.where(id: customer.shipping_addresses.first.id), :count)
        end

        it "returns an error message" do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers

          expect(parsed_response).to eq(
            {
              message: expected_errors
            }
          )
        end
      end
    end

    context "when a unlogged customer updates itself" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:user) { create(:user, id: 1) }
      let(:customer) do
        create(:customer, user:) do |customer|
          customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
        end
      end
      let(:params) do
        {
          customer: {
            user: {
              email: "newValid_email123@mail.com",
              password: "newValid_password123"
            },
            first_name: "newName",
            last_name: "newLastName",
            phone_number: "+0987654321",
            document_number: "456.789.123-49",
            document_type: "cpf",
            date_of_birth: "1987-08-08",
            addresses: {
              update: [
                {
                  id: customer.shipping_addresses.first.id,
                  line_1: "an updated residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                }
              ],
              create: [
                {
                  line_1: "a new billing address",
                  line_2: "a new billing address number",
                  zip_code: "111111",
                  city: "Manaus",
                  state: "Amazonas",
                  country: "Brazil",
                  address_type: :billing
                }
              ],
              delete: [ customer.shipping_addresses.last.id ]
            }
          }
        }
      end
      let(:expected_error) do
        customer.reload.error.map { |address| address.as_json.deep_symbolize_keys }
      end

      it "returns an unauthorized status http status code" do
        patch "/v1/customers/#{customer.id}", params: params

        expect(response).to have_http_status(:unauthorized)
      end

      it "does not update customers data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
      end

      it "does not update users data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
        expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
      end

      it "does not update the requested address data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(
          customer.reload.shipping_addresses.first.line_1
        ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
      end

      it "does not create the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
      end

      it "does not delete the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.not_to change(Address.where(id: customer.shipping_addresses.last.id), :count)
      end

      it "returns an error message" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(parsed_response).to eq(
          {
            message: I18n.t("errors.messages.invalid_access_token")
          }
        )
      end
    end

    context "when a logged customer updates another customer" do
      let(:secret) { "181a8e3baa7dc1d001e9c37dce5910ac" }
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:user) { create(:user, email: "specific-email@mail.com", id: 2) }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) do
        create(:customer) do |customer|
          customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
        end
      end
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.ee4mOg8_IdUKqhUl4FjsTotzLwLIHQDgomt8osVJ8z8"
      end
      let(:params) do
        {
          customer: {
            user: {
              email: "newValid_email123@mail.com",
              password: "newValid_password123"
            },
            first_name: "newName",
            last_name: "newLastName",
            phone_number: "+0987654321",
            document_number: "456.789.123-49",
            document_type: "cpf",
            date_of_birth: "1987-08-08",
            addresses: {
              update: [
                {
                  id: customer.shipping_addresses.first.id,
                  line_1: "an updated residential address",
                  line_2: "residential address number",
                  zip_code: "111111",
                  city: "São Paulo",
                  state: "São Paulo",
                  country: "Brazil",
                  address_type: :residential
                }
              ],
              create: [
                {
                  line_1: "a new billing address",
                  line_2: "a new billing address number",
                  zip_code: "111111",
                  city: "Manaus",
                  state: "Amazonas",
                  country: "Brazil",
                  address_type: :billing
                }
              ],
              delete: [ customer.shipping_addresses.last.id ]
            }
          }
        }
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:expected_error) do
        customer.reload.error.map { |address| address.as_json.deep_symbolize_keys }
      end

      it "returns a forbidden status http status code" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers
        expect(response).to have_http_status(:forbidden)
      end

      it "does not update customers data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.first_name).not_to eq(params[:customer][:first_name])
      end

      it "does not update users data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(customer.reload.user.authenticate(params[:customer][:user][:password])).to be_falsy
        expect(customer.reload.user.email).not_to eq(params[:customer][:user][:email])
      end

      it "does not update the requested address data" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(
          customer.reload.shipping_addresses.first.line_1
        ).not_to eq(params[:customer][:addresses][:update].first[:line_1])
      end

      it "does not create the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.not_to change(Address.where(**params[:customer][:addresses][:create].first), :count)
      end

      it "does not delete the requested address data" do
        expect do
          patch "/v1/customers/#{customer.id}", params: params, headers: headers
        end.not_to change(Address.where(id: customer.shipping_addresses.last.id), :count)
      end

      it "returns an error message" do
        patch "/v1/customers/#{customer.id}", params: params, headers: headers

        expect(parsed_response).to eq(
          {
            message: I18n.t("pundit.default")
          }
        )
      end
    end
  end

  context "DELETE /v1/customers/:id" do
    context "when a logged in customer deletes itself" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      it "returns a no content status http status code" do
        delete "/v1/customers/#{customer.id}", headers: headers

        expect(response).to have_http_status(:no_content)
      end

      it "deletes the customer" do
        expect do
          delete "/v1/customers/#{customer.id}", headers: headers
        end.to change(Customer.where(id: customer.id), :count).by(-1)
      end

      it "deletes the requested customer's associated user" do
        expect do
          delete "/v1/customers/#{customer.id}", headers: headers
        end.to change(User.where(id: customer.user_id), :count).by(-1)
      end

      it "deletes the jti registries associated with the customer's user" do
        expect do
          delete "/v1/customers/#{customer.id}", headers: headers
        end.to change(JtiRegistry.where(jti: jti_registry.jti), :count).by(-1)
      end
    end

    context "when a logged in customer tries to delete another customer" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:logged_user) { create(:user, id: 1) }
      let!(:logged_user_jti_registry) { create(:jti_registry, jti:, user: logged_user) }
      let!(:customer_to_be_deleted) { create(:customer) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      it "returns a forbidden status" do
        delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't delete the requested customer" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(Customer, :count)
      end

      it "doensn't delete the requested customer's associated user" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(User, :count)
      end

      it "doesn't delete the jti registries associated with the requested customer's user" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(JtiRegistry, :count)
      end

      it "returns an error message inside response body" do
        delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("pundit.default")
        })
      end
    end

    context "when a logged in customer that's not confirmed tries to delete another customer" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:logged_user) { create(:user, id: 1, confirmed_at: nil) }
      let!(:logged_user_jti_registry) { create(:jti_registry, jti:, user: logged_user) }
      let!(:customer_to_be_deleted) { create(:customer) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end

      it "returns a forbidden status" do
        delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't delete the requested customer" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(Customer, :count)
      end

      it "doensn't delete the requested customer's associated user" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(User, :count)
      end

      it "doesn't delete the jti registries associated with the requested customer's user" do
        expect do
          delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers
        end.not_to change(JtiRegistry, :count)
      end

      it "returns an error message inside response body" do
        delete "/v1/customers/#{customer_to_be_deleted.id}", headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("pundit.default")
        })
      end
    end

    context "when a not logged in customer tries to delete a customer" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let!(:customer) { create(:customer, user:) }

      it "returns an unauthorized http status" do
        delete "/v1/customers/#{customer.id}"

        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't delete the requested customer" do
        expect do
          delete "/v1/customers/#{customer.id}"
        end.not_to change(Customer, :count)
      end

      it "doensn't delete the requested customer's associated user" do
        expect do
          delete "/v1/customers/#{customer.id}"
        end.not_to change(User, :count)
      end

      it "doesn't delete the jti registries associated with the requested customer's user" do
        expect do
          delete "/v1/customers/#{customer.id}"
        end.not_to change(JtiRegistry, :count)
      end

      it "returns an empty body" do
        delete "/v1/customers/#{customer.id}", headers: headers

        expect(parsed_response).to eq({
          message: I18n.t("errors.messages.invalid_access_token")
        })
      end
    end

    context "when trying to delete a customer that doesn't exist" do
      let(:parsed_response) { response.parsed_body.deep_symbolize_keys }
      let(:jti) { "8eafd5e2-85b4-4432-8f39-0f5de61001fa" }
      let(:user) { create(:user, id: 1) }
      let!(:jti_registry) { create(:jti_registry, jti:, user:) }
      let(:customer) { create(:customer, user:) }
      let(:access_token) do
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEsImp0aSI6IjhlYWZkNWUyLTg1YjQtNDQzMi04ZjM5LTBmNWRlNjEwMDFmYSIsImlhdCI6NjEyOTMyNDAwLCJleHAiOjYxMjk3NTYwMCwiaXNzIjoibG9jYWxob3N0LnRlc3QifQ.Msooi3vCIgSs_y6mQFiEuMtp47F_vb3NkCpeU4jso3g"
      end
      let(:headers) do
        {
          "Authorization" => "Bearer #{access_token}"
        }
      end
      let(:invalid_id) { 'invalid_id' }

      it "returns a not found http status" do
        delete "/v1/customers/#{invalid_id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

     it "doesn't delete the requested customer" do
        expect do
          delete "/v1/customers/#{invalid_id}", headers: headers
        end.not_to change(Customer, :count)
      end

      it "doensn't delete the requested customer's associated user" do
        expect do
          delete "/v1/customers/#{invalid_id}", headers: headers
        end.not_to change(User, :count)
      end

      it "doesn't delete the jti registries associated with the requested customer's user" do
        expect do
          delete "/v1/customers/#{invalid_id}", headers: headers
        end.not_to change(JtiRegistry, :count)
      end

      it "returns an empty body" do
        delete "/v1/customers/invalid_id", headers: headers

        expect(parsed_response).to eq({
          message: "Couldn't find Customer with 'id'=#{invalid_id}"
        })
      end
    end
  end
end
