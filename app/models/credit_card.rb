# == Schema Information
#
# Table name: credit_cards
#
#  id                 :integer          not null, primary key
#  client_id          :integer
#  name_on_card       :text
#  card_type          :string(255)
#  address            :text
#  state              :string(255)
#  zip                :string(255)
#  number             :string(255)
#  city               :text
#  cvc                :integer
#  ex_month           :integer
#  ex_year            :integer
#  last_4_digits      :integer
#  stripe_card_status :string(255)      default("pending")
#  created_at         :datetime
#  updated_at         :datetime
#

class CreditCard < ActiveRecord::Base

  belongs_to :client

  validates :number, uniqueness: { scope: :client_id }

  validates_length_of  :zip,
                       :is => 5,
                       :message => "should be 5 digits"

end
