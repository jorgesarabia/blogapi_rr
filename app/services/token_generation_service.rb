# frozen_string_literal: true

class TokenGenerationService
  def self.generate
    SecureRandom.hex(10)
  end
end
