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

  monetize :discount_cents

  scope :active, ->{ where(active: true) }

  def self.generate_promocode
    SecureRandom.hex[0, 10]
  end

end
