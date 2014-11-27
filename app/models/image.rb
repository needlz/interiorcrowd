class Image < ActiveRecord::Base

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'

  has_attached_file :image, styles: { medium: "200x200>", thumb: "100x100>" }, path: ":class/:id/:style:filename"
  has_one :lookbook_details

  belongs_to :contest

  scope :liked_examples, ->{ where(kind: LIKED_EXAMPLE) }
  scope :space_images, ->{ where(kind: SPACE) }
  scope :of_kind, ->(kind){ where(kind: kind) }

  def self.update_ids(contest_id, image_ids, kind)
    old_ids = of_kind(kind).pluck(:id)
    ids_to_remove = old_ids - image_ids
    ids_to_add = image_ids - old_ids
    where(id: ids_to_remove).destroy_all
    add_images(contest_id, ids_to_add, kind)
  end

  def self.add_images(contest_id, image_ids, kind)
    where(id: image_ids).each do |image|
      image.update_attributes(contest_id: contest_id, kind: kind)
    end
  end

end
