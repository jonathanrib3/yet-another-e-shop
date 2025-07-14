require 'rails_helper'

RSpec.describe Customer, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:document_number) }
    it { is_expected.to validate_presence_of(:document_number) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to define_enum_for(:document_type) }

    context "document number format" do
      context "when is a valid CPF" do
        let(:customer) { build(:customer, document_number: "123.456.789-09", document_type: :cpf) }

        it "is valid" do
          expect(customer).to be_valid
        end
      end

      context "when is an invalid CPF" do
        let(:customer) { build(:customer, document_number: "123.456.789-0", document_type: :cpf) }

        it "is invalid" do
          expect(customer).to be_invalid
        end

        it "adds an error message to the model" do
          customer.validate
          expect(customer.errors.to_a).to eq([ "Document number #{I18n.t("errors.attributes.document_number.invalid_cpf_format")}" ])
        end
      end

      context "when is a valid RG" do
        let(:customer) { build(:customer, document_number: "36.787.939-6", document_type: :rg) }
        it "is valid" do
          expect(customer).to be_valid
        end
      end

      context "when is an invalid RG" do
        let(:customer) { build(:customer, document_number: "3.87.939-6", document_type: :rg) }

        it "is invalid" do
          expect(customer).to be_invalid
        end

        it "adds an error message to the model" do
          customer.validate
          expect(customer.errors.to_a).to eq([ "Document number #{I18n.t("errors.attributes.document_number.invalid_rg_format")}" ])
        end
      end

      context "when is a valid Passport" do
        let(:customer) { build(:customer, document_number: "TS156644", document_type: :passport) }
        it "is valid" do
          expect(customer).to be_valid
        end
      end

      context "when is an invalid Passport" do
        let(:customer) { build(:customer, document_number: "T56644", document_type: :passport) }

        it "is invalid" do
          expect(customer).to be_invalid
        end

        it "adds an error message to the model" do
          customer.validate
          expect(customer.errors.to_a).to eq([ "Document number #{I18n.t("errors.attributes.document_number.invalid_passport_format")}" ])
        end
      end

      context "when isn't a cpf, rg or passport" do
        let(:customer) { build(:customer, document_number: "T56644", document_type: :invalid) }

        it "is invalid" do
          expect(customer).to be_invalid
        end

        it "adds an error message to the model" do
          customer.validate

          expect(customer.errors.to_a).to eq(
            [ "Document type #{I18n.t("errors.messages.inclusion")}", "Document type #{I18n.t("errors.messages.invalid")}" ]
          )
        end
      end
    end

    context "uniqueness" do
      let!(:customer) { create(:customer) }

      it { is_expected.to validate_uniqueness_of(:document_number).case_insensitive }
    end

    context "residential addresses uniqueness" do
      let!(:customer) { build(:customer) }

      context "when there's more than one residential address" do
        before do
          customer.addresses << build_list(:address, 2, address_type: :residential)
        end

        it "invalidates customer's model" do
          expect(customer).to be_invalid
        end

        it "adds an error message to model's errors array" do
          customer.validate
          expect(customer.errors[:addresses]).to include(I18n.t("errors.address.attributes.user_id.duplicate_residential_address"))
        end
      end

      context "when there's only one residential address" do
        before do
          customer.addresses << build(:address, address_type: :residential)
        end

        it "validates customer's model" do
          expect(customer).to be_valid
        end

        it "does not add an error message to model's errors array" do
          customer.validate
          expect(customer.errors[:addresses]).to be_empty
        end
      end
    end

    context "billing addresses uniqueness" do
      let!(:customer) { build(:customer) }

      context "when there's more than one billing address" do
        before do
          customer.addresses << build_list(:address, 2, address_type: :billing)
        end

        it "invalidates customer's model" do
          expect(customer).to be_invalid
        end

        it "adds an error message to model's errors array" do
          customer.validate
          expect(customer.errors[:addresses]).to include(I18n.t("errors.address.attributes.user_id.duplicate_billing_address"))
        end
      end

      context "when there's only one billing address" do
        before do
          customer.addresses << build(:address, address_type: :billing)
        end

        it "validates customer's model" do
          expect(customer).to be_valid
        end

        it "does not add an error message to model's errors array" do
          customer.validate
          expect(customer.errors[:addresses]).to be_empty
        end
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:user).dependent(:destroy) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:user) }
  end

  context "instance methods" do
    context "when retrieving the customer's residential address" do
      let!(:customer) { create(:customer, :with_addresses) }
      let(:expected_residential_address) do
        customer.addresses.find { |address| address.address_type == "residential" }
      end

      it "returns the filtered residential address" do
        expect(customer.residential_address).to eq(expected_residential_address)
      end
    end

    context "when retrieving the customer's billing address" do
      let!(:customer) { create(:customer, :with_addresses) }
      let(:expected_billing_address) do
        customer.addresses.find { |address| address.address_type == "billing" }
      end

      it "returns the filtered billing address" do
        expect(customer.billing_address).to eq(expected_billing_address)
      end
    end

    context "when retrieving the customer's shipping addresses" do
      let!(:customer) { create(:customer, :with_addresses) }
      let(:expected_shipping_addresses) do
        customer.addresses.select { |address| address.address_type == "shipping" }
      end
      let(:extra_shipping_addresses) { create_list(:address, 2, address_type: :shipping, customer: customer) }

      before do
        customer.shipping_addresses << extra_shipping_addresses
      end

      it "returns the filtered shipping addresses" do
        expect(customer.reload.shipping_addresses).to eq(expected_shipping_addresses)
      end
    end
  end
end
