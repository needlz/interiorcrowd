class Image < ActiveRecord::Base

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'
  PORTFOLIO_ITEM = 'portfolio'
  PORTFOLIO_BACKGROUND = 'portfolio_background'
  PORTFOLIO_PERSONAL = 'portfolio_personal'

  UNIQUE_PORTFOLIO_ITEMS = [PORTFOLIO_PERSONAL, PORTFOLIO_BACKGROUND]

  has_attached_file :image,
                    styles: { medium: '200x200>', thumb: '100x100>' },
                    path: ':class/:id/:style:filename'
  has_one :lookbook_details

  belongs_to :contest
  belongs_to :portfolio

  scope :of_kind, ->(kind){ where(kind: kind) }
  scope :liked_examples, ->{ of_kind(LIKED_EXAMPLE) }
  scope :space_images, ->{ of_kind(SPACE) }
  scope :portfolio_pictures, ->{ of_kind(PORTFOLIO_ITEM) }
  scope :portfolio_personal_picture, ->{ of_kind(PORTFOLIO_PERSONAL) }
  scope :portfolio_background, ->{ of_kind(PORTFOLIO_BACKGROUND) }

  def self.update_contest(contest, image_ids, kind)
    update_ids(where(contest_id: contest.id).of_kind(kind),
               image_ids,
               { contest_id: contest.id, kind: kind })
  end

  def self.update_portfolio(portfolio, background_id, personal_picture_id, image_ids)
    return if background_id.blank? && image_ids.blank? && personal_picture_id.blank?
    transaction do
      if image_ids.present?
        update_ids(portfolio.pictures,
                   image_ids,
                   { portfolio_id: portfolio.id, kind: PORTFOLIO_ITEM })
      end
      update_portfolio_image(portfolio, PORTFOLIO_BACKGROUND, background_id) if background_id
      update_portfolio_image(portfolio, PORTFOLIO_PERSONAL, personal_picture_id) if personal_picture_id
    end
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

  def self.update_portfolio_image(portfolio, kind, image_id)
    if picture = Image.find_by_id(image_id)
      picture.update_attributes!(kind: kind, portfolio_id: portfolio.id)
    end
  end

  def thumbnail
    {
      name: image_file_name,
      size: image_file_size,
      url: image.url(:medium),
      id: id
    }
  end

end
