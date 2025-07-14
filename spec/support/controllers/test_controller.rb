class TestController < ActionController::API
  before_action :set_default_format
  def index; end
  def show; end
  def create; end
  def update; end
  def destroy; end

  private

  def default_render
    render json: { hello: 'world' }, status: :ok
  end

  def set_default_format
    request.format = :json
  end
end
