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
#  created_at        :datetime
#  updated_at        :datetime
#

class Promocode < ActiveRecord::Base

  has_many :contest_promocodes
  has_many :contests, through: :contest_promocodes

  monetize :discount_cents

  scope :active, ->{ where(active: true) }

  def self.generate_promocode
    SecureRandom.hex[0, 10]
  end

  def name
    promocode
  end

end
