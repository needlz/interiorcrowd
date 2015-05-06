# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  image              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  contest_id         :integer
#  kind               :string(255)
#  designer_id        :integer
#  portfolio_id       :integer
#

class Image < ActiveRecord::Base
  include Downloadable

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'
  PORTFOLIO_ITEM = 'portfolio'
  PORTFOLIO_PERSONAL = 'portfolio_personal'

  UNIQUE_PORTFOLIO_ITEMS = [PORTFOLIO_PERSONAL]

  has_attached_file :image,
                    styles: lambda { |im|
                      { medium: ['300x300>', :jpg],
                        large: ['600x600>', :jpg],
                        original_size: ['#{a.instance.width}x#{a.instance.height}>', :jpg] }
                    },
                    convert_options: {
                        all: '-background white -flatten +matte'
                    },
                    path: ':class/:id/:style:filename'
  has_one :lookbook_details

  belongs_to :contest
  belongs_to :portfolio
  has_one :image_item

  scope :of_kind, ->(kind){ where(kind: kind) }
  scope :liked_examples, ->{ of_kind(LIKED_EXAMPLE) }
  scope :space_images, ->{ of_kind(SPACE) }
  scope :portfolio_pictures, ->{ of_kind(PORTFOLIO_ITEM) }
  scope :portfolio_personal_picture, ->{ of_kind(PORTFOLIO_PERSONAL) }

  def self.update_contest(contest, image_ids, kind)
    update_ids(where(contest_id: contest.id).of_kind(kind),
               image_ids,
               { contest_id: contest.id, kind: kind })
  end

  def self.update_portfolio(portfolio, personal_picture_id, image_ids)
    return if image_ids.nil? && personal_picture_id.nil?
    transaction do
      if image_ids.present?
        update_ids(portfolio.pictures,
                   image_ids,
                   { portfolio_id: portfolio.id, kind: PORTFOLIO_ITEM })
      end
      update_portfolio_image(portfolio, PORTFOLIO_PERSONAL, personal_picture_id)
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
    portfolio_image = Image.of_kind(kind).find_by_portfolio_id(portfolio.id)
    if portfolio_image && portfolio_image.id != image_id.to_i
      portfolio_image.destroy
    end
    if picture = Image.find_by_id(image_id)
      picture.update_attributes!(kind: kind, portfolio_id: portfolio.id)
    end
  end

  def thumbnail
    {
      name: image_file_name,
      size: image_file_size,
      url: medium_size_url,
      id: id
    }
  end

  def medium_size_url
    image.url(:large)
  end

  def original_size_url
    image.url(:original_size)
  end

  def likes_count
    0
  end

  private

  def attachment
    image
  end

end
