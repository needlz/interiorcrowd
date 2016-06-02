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
#  city               :text
#  cvc                :integer
#  ex_month           :integer
#  ex_year            :integer
#  last_4_digits      :integer
#  stripe_card_status :string(255)      default("pending")
#  created_at         :datetime
#  updated_at         :datetime
#  stripe_id          :string(255)
#

class CreditCard < ActiveRecord::Base

  belongs_to :client
  has_many :client_payments
  has_many :hourly_payments

  normalize_attributes  :name_on_card, :address, :state, :city

  validates_presence_of :last_4_digits, :ex_month, :ex_year
  validates :stripe_id, uniqueness: { scope: :client_id }

  validates_length_of  :zip,
                       is: 5,
                       message: 'should be 5 digits'

  scope :from_newer_to_older, -> { order(created_at: :desc) }

  def display_name
    "##{ id }"
  end

end
