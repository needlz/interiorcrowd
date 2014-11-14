class ContestsImage < ActiveRecord::Base

  LIKED_EXAMPLE = 1
  SPACE = 2

  belongs_to :contest
  belongs_to :image

  scope :liked_examples, where(kind: LIKED_EXAMPLE)
  scope :space_images, where(kind: SPACE)

end