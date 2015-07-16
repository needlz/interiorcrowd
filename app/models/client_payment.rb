# == Schema Information
#
# Table name: client_payments
#
#  id               :integer          not null, primary key
#  client_id        :integer
#  payment_status   :string(255)      default("pending")
#  last_error       :text
#  stripe_charge_id :string(255)
#  contest_id       :integer
#

class ClientPayment < ActiveRecord::Base

  belongs_to :client
  belongs_to :contest
  normalize_attributes :last_error

  validates_uniqueness_of :contest_id

end
