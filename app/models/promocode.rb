# == Schema Information
#
# Table name: promocodes
#
#  id                :integer          not null, primary key
#  promocode         :text
#  display_message   :text
#  active            :boolean          default(TRUE)
#  discount_cents    :integer          default(0), not null
#  discount_currency :string(255)      default("USD"), not null
#

class Promocode < ActiveRecord::Base

  has_and_belongs_to_many :clients

  monetize :discount_cents

  scope :active, ->{ where(active: true) }

  def self.generate_promocode
    SecureRandom.hex[0, 10]
  end

end
