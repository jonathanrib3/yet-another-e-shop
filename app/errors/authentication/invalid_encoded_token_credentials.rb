module Errors
  module Authentication
    class InvalidEncodedTokenCredentials < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
