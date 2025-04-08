module V1
  module Admin
    class TokensController < V1::ApplicationController
      include Authenticator
      rescue_from Errors::Authentication::Revoker::TokenAlreadyBlackListed, with: :handle_token_already_black_listed

      before_action :authenticate_user!

      def black_list
        authorize :admin_user, :black_list?

        @black_listed_token = Authentication::Revoker.new(jti: black_list_token_params["jti"]).call

        render template: "v1/admin/tokens/black_list", status: :ok
      end

      private

      def black_list_token_params
        params.permit(:jti)
      end

      def handle_token_already_black_listed
        @message = I18n.t("errors.services.authentication.revoker.token_already_black_listed")
        render template: "v1/error/error", status: :unprocessable_entity
      end
    end
  end
end
