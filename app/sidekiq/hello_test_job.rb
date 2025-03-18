class HelloTestJob
  include Sidekiq::Job

  def perform(*args)
    puts "hello?"
  end
end
