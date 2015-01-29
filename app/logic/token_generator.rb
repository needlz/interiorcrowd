class TokenGenerator

  def self.generate
    SecureRandom.hex[0, 10]
  end

end
