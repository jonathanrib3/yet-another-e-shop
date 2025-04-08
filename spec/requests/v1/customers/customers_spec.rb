require 'rails_helper'

RSpec.describe "V1::CustomersController", type: :request do
  include_context "current time and authentication constants stubs"

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
                line_1: "some billing address",
                line_2: "billing address number",
                zip_code: "111111",
                city: "Manaus",
                state: "Amazônia",
                country: "Brazil",
                address_type: :billing
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
            date_of_birth: "1990-01-01"
          }
        }
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
        end.to change(Address, :count).by(5)
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

        expect(parsed_response[:customer]).to include(expected_partial_response[:customer])
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
            date_of_birth: "1990-01-01"
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
            date_of_birth: "1990-01-01"
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
            date_of_birth: nil
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
            date_of_birth: nil
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
                address_type: :shipping
              }
            ]
          }
        }
      end
      let(:expected_errors) do
        "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_residential_address")}, " \
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
end
