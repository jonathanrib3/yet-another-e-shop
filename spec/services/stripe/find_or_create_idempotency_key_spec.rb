require 'rails_helper'

RSpec.describe Stripe::FindOrCreateIdempotencyKey, type: :service do
  subject(:find_or_create_idempotency_key) do
    described_class.new(idempotency_keys_repository:, customer_id:, operation:)
  end

  context "when creating a new idempotency key with valid operation" do
    let(:idempotency_key) { "65aae266-55e3-443b-b048-152008a3eb27" }
    let(:customer_id) { 1 }
    let(:operation) { "create" }
    let(:expected_name) do
      "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:#{operation}_customer_#{customer_id}"
    end
    let(:idempotency_keys_repository) { instance_double(IdempotencyKeysRepository, find_by_name: nil, create: idempotency_key) }

    before do
      allow(Digest::UUID).to receive(:uuid_v4).and_return(idempotency_key)
      allow(IdempotencyKeysRepository).to receive(:new).and_return(idempotency_keys_repository)
    end

    it "calls idempotency keys repository's find by name with right args" do
      find_or_create_idempotency_key.call
      expect(idempotency_keys_repository).to have_received(:find_by_name).with(expected_name)
    end

    it "calls idempotency keys repository's create with right args" do
      find_or_create_idempotency_key.call
      expect(idempotency_keys_repository).to have_received(:create).with(name: expected_name, value: idempotency_key)
    end

    it "returns the created idempotency key" do
      expect(find_or_create_idempotency_key.call).to eq(idempotency_key)
    end
  end

  context "when finding an existing idempotency key with valid operation" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:customer_id) { 1 }
    let(:operation) { "update" }
    let(:expected_name) do
      "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:#{operation}_customer_#{customer_id}"
    end
    let(:idempotency_keys_repository) do
      instance_double(IdempotencyKeysRepository, find_by_name: idempotency_key, create: idempotency_key)
    end

    before do
      allow(IdempotencyKeysRepository).to receive(:new).and_return(idempotency_keys_repository)
    end

    it "calls find by name with right args" do
      find_or_create_idempotency_key.call
      expect(idempotency_keys_repository).to have_received(:find_by_name).with(expected_name)
    end

    it "returns the found idempotency key" do
      expect(find_or_create_idempotency_key.call).to eq(idempotency_key)
    end
  end

  context "when creating a new idempotency key with invalid operation" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:customer_id) { 1 }
    let(:operation) { "anything that is not create, update or delete" }
    let(:idempotency_keys_repository) { instance_double(IdempotencyKeysRepository, find_by_name: nil, create: idempotency_key) }

    before do
      allow(IdempotencyKeysRepository).to receive(:new).and_return(idempotency_keys_repository)
    end

    it "raises a Stripe::FindOrCreateIdempotencyKey::InvalidOperation error" do
      expect { find_or_create_idempotency_key.call }.to raise_error(
        Errors::Stripe::FindOrCreateIdempotencyKey::InvalidOperation
      )
    end
  end
end
