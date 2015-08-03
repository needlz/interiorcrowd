# == Schema Information
#
# Table name: contests_promocodes
#
#  contest_id   :integer          not null
#  promocode_id :integer          not null
#  id           :integer          not null, primary key
#

class ContestPromocode < ActiveRecord::Base
  self.table_name = 'contests_promocodes'

  belongs_to :contest
  belongs_to :promocode

end
