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
  end

  context "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:addresses) }
  end
end
