# == Schema Information
#
# Table name: giftcard_payments
#
#  id               :integer          not null, primary key
#  stripe_charge_id :string
#  price_cents      :integer
#  quantity         :integer
#  email            :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  first_name       :string
#  last_name        :string
#  brokerage        :string
#  phone            :string
#

class GiftcardPayment < ActiveRecord::Base

  QUANTITY_PRICES = {
    (1..4) => 299,
    (5..9) => 1375 / 5,
    (10..19) => 2500 / 10,
    (20..Float::INFINITY) => 3980 / 20
  }

  def self.price_per_item(quantity)
    QUANTITY_PRICES.find { |range, price| range.include?(quantity) }[1]
  end

  validates :email, email: true
  validates_numericality_of :quantity, greater_than: 0

end
