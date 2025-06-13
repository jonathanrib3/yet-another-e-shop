require 'rails_helper'
RSpec.describe Stripe::SendCustomerDataJob, type: :job do
  context "when sending customer data to Stripe API and it doesn't fail" do
    let!(:customer) { create(:customer, :with_addresses) }
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:stripe_customer_id) { "cus_arbitrarykey" }
    let(:stripe_create_customer_service) { instance_double(Stripe::CreateCustomer, call: { id: stripe_customer_id }) }
    let(:create_idempotency_key_service) { instance_double(Stripe::FindOrCreateIdempotencyKey, call: idempotency_key) }

    before do
      allow(Stripe::CreateCustomer).to receive(:new).and_return(stripe_create_customer_service)
      allow(Stripe::FindOrCreateIdempotencyKey).to receive(:new).and_return(create_idempotency_key_service)
    end

    it "creates an idempotency key to be used on stripe customer creation request" do
      Stripe::SendCustomerDataJob.perform_async(customer.id)
      Stripe::SendCustomerDataJob.drain

      expect(stripe_create_customer_service).to have_received(:call).once
    end

    it "sends customer data to stripe" do
      Stripe::SendCustomerDataJob.perform_async(customer.id)
      Stripe::SendCustomerDataJob.drain

      expect(stripe_create_customer_service).to have_received(:call).once
    end

    it "updates customer's stripe id attribute" do
      Stripe::SendCustomerDataJob.perform_async(customer.id)
      Stripe::SendCustomerDataJob.drain

      expect(customer.reload.stripe_customer_id).to eq(stripe_customer_id)
    end
  end

  context "when sending customer data to Stripe API and it fails due to not existing a customer with requested id" do
    let!(:customer) { create(:customer, :with_addresses) }
    let(:stripe_create_customer_service) { instance_double(Stripe::CreateCustomer, call: { id: "customer_id" }) }

    before do
      allow(Stripe::CreateCustomer).to receive(:new).and_return(stripe_create_customer_service)
    end

    it "throws an ActiveRecord::RecordNotFound error" do
      expect do
        Stripe::SendCustomerDataJob.perform_async(1912)
        Stripe::SendCustomerDataJob.drain
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not update customer's stripe id attribute" do
      Stripe::SendCustomerDataJob.perform_async(1912)
      Stripe::SendCustomerDataJob.drain rescue nil

      expect(customer.reload.stripe_customer_id).to be_nil
    end
  end

  context "when sending customer data to Stripe API and it fails due to an integration failure with Stripe" do
    let!(:customer) { create(:customer, :with_addresses) }
    let(:stripe_create_customer_service) { instance_double(Stripe::CreateCustomer, call: -> { raise StandardError }) }

    before do
      allow(Stripe::CreateCustomer).to receive(:new).and_return(stripe_create_customer_service)
    end

    it "does not update customer's stripe id attribute" do
      Stripe::SendCustomerDataJob.perform_async(customer.id)
      Stripe::SendCustomerDataJob.drain rescue nil

      expect(customer.reload.stripe_customer_id).to be_nil
    end
  end
end
