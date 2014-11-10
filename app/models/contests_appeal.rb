class ContestsAppeal < ActiveRecord::Base

  belongs_to :contest
  belongs_to :appeal

end
