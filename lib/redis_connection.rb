module RedisConnection
  def self.cache_database
    @cache_database ||= ConnectionPool::Wrapper.new(size: ENV.fetch("RAILS_MAX_THREADS", 3)) do
      Redis.new(url: ENV["RAILS_CACHE_URL"])
    end
  end
end
