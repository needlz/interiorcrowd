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

  has_and_belongs_to_many :clients

  scope :active, ->{ where(active: true) }

  def self.generate_token
    SecureRandom.hex[0, 10]
  end

end
