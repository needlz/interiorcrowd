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
#  uploader_role      :string(255)
#  uploader_id        :integer
#

class Image < ActiveRecord::Base
  include Downloadable

  LIKED_EXAMPLE = 'liked_example'
  SPACE = 'space'
  PORTFOLIO_ITEM = 'portfolio'
  PORTFOLIO_PERSONAL = 'portfolio_personal'

  UNIQUE_PORTFOLIO_ITEMS = [PORTFOLIO_PERSONAL]

  has_attached_file :image,
                    styles: lambda { |image|
                      if image.queued_for_write[:original]
                        begin
                          Paperclip::GeometryDetector.new(image.queued_for_write[:original].instance_variable_get(:@tempfile)).make
                          image.instance.file_type = 'image'
                        rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
                          image.instance.file_type = 'file'
                          return {}
                        end
                      end
                      { medium: ['300x300>', :jpg],
                        large: ['600x600>', :jpg],
                        original_size: ['', :jpg] }
                    },
                    convert_options: {
                      all: '-background white -flatten +matte'
                    },
                    path: ':class/:id/:style:filename',
                    default_url: ->(image){
                      image.processing? ? image.options[:url] : 'missing.png'
                    }
  process_in_background :image
  do_not_validate_attachment_file_type :image

  def move_from_temporary
    if image.job_is_processing == true
      s3 = AWS::S3.new
      filename = image_file_name
      path = 'temporary/' + filename
      bucket_name = Settings.aws.bucket_name
      bucket = s3.buckets[bucket_name]
      new_path = image.interpolator.interpolate(':class/:id/:style:filename', image, :original)
      bucket.objects[path].copy_to(new_path, acl: :public_read, copy_source: new_path)
    end
  end

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
    image_ids ||= []
    transaction do
      update_ids(portfolio.pictures,
                 image_ids,
                 { portfolio_id: portfolio.id, kind: PORTFOLIO_ITEM })
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
    return if image_id.nil?
    if picture = Image.find_by_id(image_id)
      picture.update_attributes!(kind: kind, portfolio_id: portfolio.id)
    end
  end

  def thumbnail
    {
      name: image_file_name,
      size: image_file_size,
      url: medium_size_url,
      small_size_url: small_size_url,
      original_size_url: original_size_url,
      download_url: url_for_downloading,
      id: id
    }
  end

  def small_size_url
    thumb_url_for(:medium)
  end

  def medium_size_url
    thumb_url_for(:large)
  end

  def original_size_url
    thumb_url_for(:original_size)
  end

  def likes_count
    0
  end

  def uploader
    return unless uploader_id && uploader_role
    uploader_class = uploader_role.constantize
    uploader_class.find(uploader_id)
  end

  def viewable?
    file_type == 'image'
  end

  private

  def attachment
    image
  end

  def thumb_url_for(style)
    if viewable?
      if image.processing?
        "/assets/thumbnail_is_being_generated.svg?image_id=#{ id }&ready_url=#{ image.url(style) }"
      else
        image.url(style)
      end
    else
      '/assets/file-icon.png'
    end
  end

end

class Paperclip::Attachment

  def reprocess_with_moving
    instance.move_from_temporary
    reprocess_without_moving
  end

  alias_method :reprocess_without_moving, :reprocess!
  alias_method :reprocess!, :reprocess_with_moving

end
