class ContestsImage < ActiveRecord::Base

  LIKED_EXAMPLE = 1
  SPACE = 2

  belongs_to :contest
  belongs_to :image

end