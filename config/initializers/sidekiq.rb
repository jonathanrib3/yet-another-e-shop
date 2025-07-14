# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_SIDEKIQ_URL', 'redis://localhost:6379/0') }
end

SCHEDULE_FILE = 'config/schedule.yml'

Sidekiq::Cron::Job.load_from_hash YAML.load_file(SCHEDULE_FILE) if File.exist?(SCHEDULE_FILE) && Sidekiq.server?
