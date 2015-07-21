# == Schema Information
#
# Table name: image_items
#
#  id                   :integer          not null, primary key
#  name                 :text
#  contest_request_id   :integer
#  image_id             :integer
#  text                 :text
#  brand                :text
#  link                 :text
#  mark                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  kind                 :string(255)
#  dimensions           :text
#  price                :text
#  status               :string(255)      default("temporary")
#  final                :boolean          default(FALSE)
#  temporary_version_id :integer
#

class ImageItem < ActiveRecord::Base

  MARKS = {
    LIKE: 'ok',
    DISLIKE: 'remove'
  }

  KINDS = %i(product_items similar_styles)
  STATUSES = %w(temporary published)

  validates_inclusion_of :mark, in: MARKS.values, allow_nil: true
  validates_inclusion_of :kind, in: KINDS.map(&:to_s)
  validates_inclusion_of :status, in: STATUSES
  validates_presence_of :contest_request

  belongs_to :image
  belongs_to :contest_request
  belongs_to :temporary_version, class_name: 'ImageItem'
  has_one :published_version, class_name: 'ImageItem', foreign_key: :temporary_version_id

  KINDS.each do |kind|
    scope kind, ->{ where(kind: kind.to_s) }
  end

  scope :for_view, ->{ order(:created_at).includes(:image) }
  scope :for_mark, ->{ where("image_id is not NULL").order(:created_at).includes(:image) }
  scope :liked, ->{ where(mark: MARKS[:LIKE]) }

  scope :initial, ->{ none }
  scope :collaboration, ->{ all }
  scope :final_design, ->{ where('final = ? OR mark = ? OR mark IS NULL', true, MARKS[:LIKE]) }

  scope :published, ->{ where(status: 'published') }
  scope :temporary, ->{ where(status: 'temporary') }

  def medium_size_image_url
    image.try(:medium_size_url)
  end

  def image_id
    image.try(:id)
  end

end
