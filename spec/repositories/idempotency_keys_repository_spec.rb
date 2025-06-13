require 'rails_helper'

RSpec.describe IdempotencyKeysRepository do
  subject(:idempotency_keys_repository) { described_class.new }

  context "when finding an existing idempotency key by its name" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:idempotency_key_name) do
      "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:delete_customer_123"
    end
    let(:redis_double) { instance_double(Redis, get: idempotency_key) }

    before do
      allow(RedisConnection).to receive(:cache_database).and_return(redis_double)
    end

    it "calls redis 'get' method with right args" do
      idempotency_keys_repository.find_by_name(idempotency_key_name)

      expect(redis_double).to have_received(:get).with(idempotency_key_name)
    end

    it "returns the existing idempotency key" do
      expect(idempotency_keys_repository.find_by_name(idempotency_key_name)).to eq(idempotency_key)
    end
  end

  context "when finding an idempotency key that doesn't exist" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:idempotency_key_name) do
      "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:delete_customer_123"
    end
    let(:redis_double) { instance_double(Redis, get: nil) }

    before do
      allow(RedisConnection).to receive(:cache_database).and_return(redis_double)
    end

    it "calls redis 'get' method with right args" do
      idempotency_keys_repository.find_by_name(idempotency_key_name)

      expect(redis_double).to have_received(:get).with(idempotency_key_name)
    end

    it "returns nil" do
      expect(idempotency_keys_repository.find_by_name(idempotency_key_name)).to be_nil
    end
  end

  context "when creating a new idempotency key" do
    let(:idempotency_key) { Digest::UUID.uuid_v4 }
    let(:idempotency_key_name) do
      "#{Stripe::Constants::IDEMPOTENCY_KEYS_NAME_PREFIX}:delete_customer_123"
    end
    let(:redis_double) { instance_double(Redis, set: 1, expire: 1) }

    before do
      allow(RedisConnection).to receive(:cache_database).and_return(redis_double)
    end

    it "calls redis 'set' method with right args" do
      idempotency_keys_repository.create(name: idempotency_key_name, value: idempotency_key)

      expect(redis_double).to have_received(:set).with(idempotency_key_name, idempotency_key)
    end

    it "calls redis 'expire' method with right args" do
      idempotency_keys_repository.create(name: idempotency_key_name, value: idempotency_key)

      expect(redis_double).to have_received(:expire).with(idempotency_key_name, 86400)
    end

    it "returns the existing idempotency key" do
      expect(
        idempotency_keys_repository.create(name: idempotency_key_name, value: idempotency_key)
      ).to eq(idempotency_key)
    end
  end
end
