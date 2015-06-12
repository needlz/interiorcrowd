# == Schema Information
#
# Table name: promocodes
#
#  id        :integer          not null, primary key
#  client_id :integer
#  token     :text
#  profit    :text
#

class Promocode < ActiveRecord::Base

  belongs_to :client

  scope :unused, ->{ where(client_id: nil) }

  def self.generate_token
    SecureRandom.hex[0, 10]
  end

end
