module Tokens
  SECRET = ENV.fetch("RANDOM_TOKENS_SECRET", "sekret")

  def self.generate_random_token
    Digest::SHA256.hexdigest(SecureRandom.random_bytes(32) + SECRET)
  end

  private_constant :SECRET
end
