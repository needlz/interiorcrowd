# == Schema Information
#
# Table name: contests_appeals
#
#  id         :integer          not null, primary key
#  contest_id :integer
#  appeal_id  :integer
#  reason     :text
#  value      :integer
#

class ContestsAppeal < ActiveRecord::Base

  belongs_to :contest
  belongs_to :appeal

  scope :ordered_by_appeal, ->{ includes(:appeal).order('appeals.id') }

end
