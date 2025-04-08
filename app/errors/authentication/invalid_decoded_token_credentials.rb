module Errors
  module Authentication
    class InvalidDecodedTokenCredentials < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
