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
#  stripe_id          :string(255)
#

class CreditCard < ActiveRecord::Base
  before_save :set_last_4_digits

  belongs_to :client

  normalize_attributes  :name_on_card, :address, :state, :city

  validates_presence_of :number, :ex_month, :ex_year, :cvc
  validates :number, uniqueness: { scope: :client_id }

  validates_length_of  :zip,
                       is: 5,
                       message: 'should be 5 digits'

  validates_numericality_of :cvc, :on => [:create, :update, :save]

  scope :from_newer_to_older, -> { order(created_at: :desc) }

  def set_last_4_digits
    self.last_4_digits= number.length < 4 ? number : number[-4..-1]
  end

end
