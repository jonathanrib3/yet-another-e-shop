module Authentication
  module Constants
    EXPIRY_TIME_IN_HOURS = 12
    REFRESH_TOKEN_EXPIRY_TIME_IN_DAYS = 30
    JWT_SECRET = ENV.fetch('JWT_SECRET', 'secret')
    JWT_ISSUER = ENV.fetch('JWT_ISSUER', 'localhost')
    JWT_ALGORITHM_HEADER = 'HS256'.freeze
    JWT_TYP_HEADER = 'JWT'.freeze
    JWT_ACCESS_TOKEN_RETRIEVAL_REGEX = /Bearer\s(?<access_token>[\w-]+\.[\w-]+\.[\w-]+$)/
  end
end
