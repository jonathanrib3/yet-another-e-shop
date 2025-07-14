# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.2'

gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', require: false
gem 'faker', '~> 3.5'
gem 'faraday', '~> 2.12', '>= 2.12.2'
gem 'jbuilder', '~> 2.13'
gem 'jwt', '~> 2.10', '>= 2.10.1'
gem 'kamal', require: false
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'pundit', '~> 2.5'
gem 'rails', '~> 8.0.2'
gem 'redis', '~> 5.4'
gem 'sidekiq', '~> 8.0'
gem 'sidekiq-cron', '~> 2.1'
gem 'solid_cache'
gem 'stripe', '~> 13.5'
gem 'thruster', require: false
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'dotenv', '~> 3.1', '>= 3.1.7'
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.4'
  gem 'guard-rspec', '~> 4.7', '>= 4.7.3'
  gem 'rspec-rails', '~> 7.0.0'
  gem 'rubocop-rails', '~> 2.32', require: false
  gem 'rubocop-rspec_rails', '~> 2.31', require: false
end

group :development do
  gem 'bullet', '~> 8.0', '>= 8.0.8'
  gem 'letter_opener', '~> 1.10'
  gem 'letter_opener_web', '~> 3.0'
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'webmock', '~> 3.25', '>= 3.25.1'
end
