class Promocode < ActiveRecord::Base

  belongs_to :client

  scope :unused, ->{ where(client_id: nil) }

  def self.generate_token
    SecureRandom.hex[0, 10]
  end

end
