class IdempotencyKeysRepository
  IDEMPOTENCY_KEYS_DEFAULT_TTL = 86400

  def initialize
    @redis_database = RedisConnection.cache_database
  end

  def create(name:, value:)
    @redis_database.set(name, value)
    add_expiration_time_on_created_idempotency_set(name)

    value
  end

  def find_by_name(name)
    @redis_database.get(name)
  end

  private

  private_constant :IDEMPOTENCY_KEYS_DEFAULT_TTL

  def add_expiration_time_on_created_idempotency_set(name)
    @redis_database.expire(name, IDEMPOTENCY_KEYS_DEFAULT_TTL)
  end
end
