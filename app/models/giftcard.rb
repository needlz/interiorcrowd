# == Schema Information
#
# Table name: giftcards
#
#  id                  :integer          not null, primary key
#  giftcard_payment_id :integer
#  code                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Giftcard < ActiveRecord::Base

  belongs_to :giftcard_payment

  def self.generate
    new(code: TokenGenerator.generate)
  end

end
