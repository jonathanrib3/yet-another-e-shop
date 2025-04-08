require 'rails_helper'

RSpec.describe Stripe::CreateCustomer, type: :service do
  subject(:stripe_create_customer) { described_class.new(customer:, idempotency_key:) }

  context "when creating customer data in Stripe and it is successful" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:customer) { create(:customer, :with_addresses) }
    let(:api_key) { "fakeapikey" }
    let(:stripe_response_body) do
      {
        id: "cus_randomarbitraryid",
        name: "#{customer.first_name} #{customer.last_name}",
        email: customer.user.email,
        phone: customer.phone_number,
        address: {
          city: customer.residential_address.city,
          country: customer.residential_address.country,
          line1: customer.residential_address.line_1,
          line2: customer.residential_address.line_2,
          postal_code: customer.residential_address.zip_code,
          state: customer.residential_address.state
        },
        balance: 0,
        created: Time.now.to_i,
        currency: nil,
        default_source: nil,
        delinquent: false,
        description: nil,
        discount: nil,
        invoice_prefix: 'DF2C3EDC',
        invoice_settings: {
          custom_fields: nil,
          default_payment_method: nil,
          footer: nil,
          rendering_options: nil
        },
        livemode: false,
        metadata: {},
        next_invoice_sequence: 1,
        preferred_locales: [],
        shipping: nil,
        tax_exempt: 'none',
        test_clock: nil
      }
    end

    before do
      stub_const("Stripe::Constants::API_KEY", api_key)
      stub_request(:post, "#{Stripe::Constants::API_BASE_URL}/customers")
      .with(
        headers: {
        "Authorization" =>"Bearer #{api_key}",
        "Idempotency-Key" => idempotency_key
      })
      .to_return(
        body: JSON.generate(stripe_response_body),
        status: 200)
    end

    it "returns the created customer id" do
      expect(stripe_create_customer.call).to eq(
        {
          id: stripe_response_body[:id],
          name: stripe_response_body[:name],
          email: stripe_response_body[:email],
          address: stripe_response_body[:address],
          phone: stripe_response_body[:phone]
        }
      )
    end
  end
end
