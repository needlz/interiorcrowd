class Image < ActiveRecord::Base

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'

  has_attached_file :image, styles: { medium: "200x200>", thumb: "100x100>" }, path: ":class/:id/:style:filename"
  has_one :lookbook_details

  belongs_to :contest

  scope :liked_examples, ->{ where(kind: LIKED_EXAMPLE) }
  scope :space_images, ->{ where(kind: SPACE) }
  scope :of_kind, ->(kind){ where(kind: kind) }

end
