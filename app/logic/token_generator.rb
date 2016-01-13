class TokenGenerator

  def self.generate(length = 5)
    SecureRandom.hex[0, length * 2]
  end

end
