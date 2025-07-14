require 'rails_helper'

RSpec.describe Customers::Update, type: :service do
  subject(:update_customer) { described_class.new(customer: customer, update_customer_data:) }

  context "when updating a customer's data, user's credentials and creating, deleting or updating customer's addresses with valid data" do
    let(:customer) do
      create(:customer) do |customer|
        customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
      end
    end
    let(:update_customer_data) do
      {
        user: {
          email: "newValid_email123@mail.com",
          password: "newValid_password123"
        },
        first_name: "newName",
        last_name: "newLastName",
        phone_number: "+0987654321",
        document_number: "456.789.123-49",
        document_type: "cpf",
        date_of_birth: "2001-09-01",
        addresses: {
          update: [
            {
              id: customer.shipping_addresses.last.id,
              line_1: "an updated billing address",
              line_2: "billing address number",
              zip_code: "03625100",
              city: "São Paulo",
              state: "São Paulo",
              country: "Brazil",
              address_type: 'billing'
            }
          ],
          create: [
            {
              line_1: "a new residential address",
              line_2: "a new residential address number",
              zip_code: "04898140",
              city: "Manaus",
              state: "Amazonas",
              country: "Brazil",
              address_type: 'residential'
            }
          ],
          delete: [ customer.shipping_addresses.first.id ]
        }
      }
    end
    let(:updated_customer_data) do
      {
        first_name: "newName",
        last_name: "newLastName",
        phone_number: "+0987654321",
        document_number: "456.789.123-49",
        document_type: "cpf",
        date_of_birth: "2001-09-01"
      }
    end

    it "updates customer's user attributes" do
      subject.call

      expect(customer.reload.as_json.deep_symbolize_keys).to include(updated_customer_data)
    end

    it "updates customer's data" do
      subject.call

      expect(customer.reload.as_json.deep_symbolize_keys).to include(updated_customer_data)
    end

    it 'creates new addresseses' do
      expect { subject.call }.to change(
        Address.where(line_1: update_customer_data[:addresses][:create].first[:line_1]
          ), :count).by(1)
    end

    it 'updates requested addresses' do
      subject.call

      expect(
        customer.billing_address.as_json.deep_symbolize_keys
      ).to include(update_customer_data[:addresses][:update].first)
    end

    it 'deletes specified addresses' do
      subject.call
      expect(Address.exists?(id: update_customer_data[:addresses][:delete].first)).to be_falsy
    end
  end

  context "when updating a customer's data, user's credentials and creating, deleting or updating customer's addresses with invalid data" do
    context "when user data is invalid" do
      let(:customer) do
        create(:customer) do |customer|
          customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
        end
      end
      let(:update_customer_data) do
      {
        user: {
          email: "inalid_email123@123.com",
          password: "inalid_password123"
        }
      }
      end
      let(:expected_error) do
        "Validation failed: User email #{I18n.t("errors.attributes.email.invalid")}, " \
        "User password #{I18n.t("errors.attributes.password.invalid")}"
      end


      it "raises an ActiveRecord::RecordInvalid error" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid, expected_error)
      end
    end

    context "when customer data is invalid" do
      let(:customer) do
        create(:customer) do |customer|
          customer.addresses << create_list(:address, 2, address_type: :shipping, customer:)
        end
      end
      let(:update_customer_data) do
        {
          first_name: nil,
          last_name: nil,
          phone_number: nil,
          document_number: 'invalid_cpf',
          document_type: 'cpf',
          date_of_birth: nil
        }
      end
      let(:expected_error) do
        "Validation failed: First name #{I18n.t("errors.messages.blank")}, " \
        "Last name #{I18n.t("errors.messages.blank")}, " \
        "Phone number #{I18n.t("errors.messages.blank")}, " \
        "Date of birth #{I18n.t("errors.messages.blank")}, " \
        "Document number #{I18n.t("errors.attributes.document_number.invalid_cpf_format")}" \
      end


      it "raises an ActiveRecord::RecordInvalid error" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid, expected_error)
      end
    end

    context "when addresses data has invalid data to create or update any addresses" do
      let(:customer) do
        create(:customer) do |customer|
          customer.addresses << create(:address, address_type: :shipping, customer:)
          customer.addresses << create(:address, address_type: :residential, customer:)
          customer.addresses << create(:address, address_type: :billing, customer:)
        end
      end

      let(:update_customer_data) do
      {
        addresses: {
          update: [
            {
              id: customer.shipping_addresses.first.id,
              line_1: nil,
              line_2: nil,
              zip_code: nil,
              city: nil,
              state: nil,
              country: nil,
              address_type: 'billing'
            }
          ],
          create: [
            {
              line_1: "a new residential address",
              line_2: "a new residential address number",
              zip_code: "04898140",
              city: "Manaus",
              state: "Amazonas",
              country: "Brazil",
              address_type: 'residential'
            }
          ],
          delete: [ customer.residential_address.id ]
        }
      }
      end
      let(:expected_error) do
        "Validation failed: Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_residential_address")}, " \
        "Addresses #{I18n.t("errors.address.attributes.user_id.duplicate_billing_address")}, " \
        "Addresses line 1 #{I18n.t("errors.messages.blank")}, " \
        "Addresses zip code #{I18n.t("errors.messages.blank")}, " \
        "Addresses city #{I18n.t("errors.messages.blank")}, " \
        "Addresses state #{I18n.t("errors.messages.blank")}, " \
        "Addresses country #{I18n.t("errors.messages.blank")}"
      end

      it "raises an ActiveRecord::RecordInvalid error" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid, expected_error)
      end
    end

    context "when addresses data has invalid ids to delete any address" do
      let(:customer) do
        create(:customer) do |customer|
          customer.addresses << create(:address, address_type: :shipping, customer:)
        end
      end

      let(:update_customer_data) do
      {
        addresses: {
          delete: [ 'invalid_id' ]
        }
      }
      end
      let(:expected_error) do
        "Couldn't find Address with ID=#{update_customer_data.dig(:addresses, :delete).first} " \
        "for Customer with ID=#{customer.id}"
      end

      it "raises an ActiveRecord::RecordNotFound error" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordNotFound, expected_error)
      end
    end
  end
end
