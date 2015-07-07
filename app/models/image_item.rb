# == Schema Information
#
# Table name: image_items
#
#  id                 :integer          not null, primary key
#  name               :text
#  contest_request_id :integer
#  image_id           :integer
#  text               :text
#  brand              :text
#  link               :text
#  mark               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  kind               :string(255)
#  dimensions         :text
#  final              :boolean          default(FALSE)
#  price              :text
#

class ImageItem < ActiveRecord::Base

  MARKS = {
    LIKE: 'ok',
    DISLIKE: 'remove'
  }

  KINDS = %i(product_items similar_styles)

  validates_inclusion_of :mark, in: MARKS.values, allow_nil: true
  validates_inclusion_of :kind, in: KINDS.map(&:to_s)
  validates_presence_of :contest_request

  belongs_to :image, dependent: :destroy
  belongs_to :contest_request

  KINDS.each do |kind|
    scope kind, ->{ where(kind: kind.to_s) }
  end

  scope :for_view, ->{ order(:created_at).includes(:image) }
  scope :for_mark, ->{ where("image_id is not NULL").order(:created_at).includes(:image) }
  scope :liked, ->{ where(mark: MARKS[:LIKE]) }
  scope :final_design, ->{ where('final = ? OR mark = ? OR mark IS NULL', true, MARKS[:LIKE]) }
  scope :collaboration, ->{ all }
  scope :initial, ->{ none }

  def medium_size_image_url
    image.try(:medium_size_url)
  end

  def image_id
    image.try(:id)
  end

end
