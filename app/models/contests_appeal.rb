class ContestsAppeal < ActiveRecord::Base

  belongs_to :contest
  belongs_to :appeal

  scope :ordered_by_appeal, ->{ includes(:appeal).order('appeals.id') }

end
