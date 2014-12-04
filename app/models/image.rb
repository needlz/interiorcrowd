class Image < ActiveRecord::Base

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'
  PORTFOLIO_ITEM = 'portfolio'

  has_attached_file :image,
                    styles: { medium: '200x200>', thumb: '100x100>' },
                    path: ':class/:id/:style:filename'
  has_one :lookbook_details

  belongs_to :contest
  belongs_to :designer

  scope :of_kind, ->(kind){ where(kind: kind) }
  scope :liked_examples, ->{ of_kind(LIKED_EXAMPLE) }
  scope :space_images, ->{ of_kind(SPACE) }
  scope :portfolio_pictures, ->{ of_kind(PORTFOLIO_ITEM) }

  def self.update_contest(contest, image_ids, kind)
    update_ids(where(contest_id: contest.id).of_kind(kind),
               image_ids,
               { contest_id: contest.id, kind: kind })
  end

  def self.update_portfolio(designer, image_ids)
    update_ids(designer.portfolio_pictures,
               image_ids,
               { designer_id: designer.id, kind: PORTFOLIO_ITEM })
  end

  def self.update_ids(old_ids_container, ids, update_attributes)
    transaction do
      old_ids = old_ids_container.pluck(:id)
      ids_to_remove = old_ids - ids
      where(id: ids_to_remove).destroy_all if ids_to_remove.present?
      ids_to_add = ids - old_ids
      where(id: ids_to_add).update_all(update_attributes) if ids_to_add.present?
    end
  end
end
