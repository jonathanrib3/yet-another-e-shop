class HelloTestJob
  include Sidekiq::Job

  def perform(*_args)
    puts 'hello?' # rubocop:disable Rails/Output
  end
end
