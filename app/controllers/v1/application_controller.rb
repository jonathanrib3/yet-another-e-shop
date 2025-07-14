module V1
  class ApplicationController < ::ApplicationController
    include Pundit::Authorization
    before_action :set_default_format
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def set_default_format
      request.format = :json
    end

    def user_not_authorized
      @message = I18n.t('pundit.default')

      render template: 'v1/error/error', status: :forbidden
    end

    def record_invalid(exception)
      @message = exception.message.gsub('Validation failed: ', '')

      render template: 'v1/error/error', status: :unprocessable_entity
    end

    def record_not_found(exception)
      @message = exception.message

      render template: "v1/error/error", status: :not_found
    end
  end
end
