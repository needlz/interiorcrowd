# == Schema Information
#
# Table name: preferred_retailers
#
#  id                   :integer          not null, primary key
#  anthropologie_home   :boolean          default(FALSE)
#  ballard_designs      :boolean          default(FALSE)
#  crate_and_barrel     :boolean          default(FALSE)
#  etsy                 :boolean          default(FALSE)
#  gilt                 :boolean          default(FALSE)
#  horchow              :boolean          default(FALSE)
#  ikea                 :boolean          default(FALSE)
#  one_kings_lane       :boolean          default(FALSE)
#  pier_one             :boolean          default(FALSE)
#  pottery_barn         :boolean          default(FALSE)
#  restoration_hardware :boolean          default(FALSE)
#  room_and_board       :boolean          default(FALSE)
#  target               :boolean          default(FALSE)
#  wayfair              :boolean          default(FALSE)
#  west_elm             :boolean          default(FALSE)
#  other                :text
#  created_at           :datetime
#  updated_at           :datetime
#

class PreferredRetailers < ActiveRecord::Base

  RETAILERS = %i(anthropologie_home ballard_designs crate_and_barrel etsy gilt horchow ikea one_kings_lane pier_one
         pottery_barn restoration_hardware room_and_board target wayfair west_elm)

  has_one :contest

end
