# == Schema Information
#
# Table name: hourly_payments
#
#  id                   :integer          not null, primary key
#  client_id            :integer
#  payment_status       :string
#  last_error           :text
#  stripe_charge_id     :string
#  time_tracker_id      :integer
#  credit_card_id       :integer
#  hours_count          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  total_price_in_cents :integer
#

class HourlyPayment < ActiveRecord::Base
  belongs_to :time_tracker
  belongs_to :client
  belongs_to :credit_card

  normalize_attributes :last_error

end
