class ImageItem < ActiveRecord::Base

  self.table_name = 'product_items'

  MARKS = {
    LIKE: 'ok',
    DISLIKE: 'remove'
  }

  KINDS = %i(product_items similar_styles)

  validates_inclusion_of :mark, in: MARKS.values, allow_nil: true
  validates_inclusion_of :kind, in: KINDS.map(&:to_s)

  belongs_to :image, dependent: :destroy
  belongs_to :contest_request

  KINDS.each do |kind|
    scope kind, ->{ where(kind: kind.to_s) }
  end

  scope :for_view, ->{ order(:created_at).includes(:image) }
  scope :liked, ->{ where(mark: MARKS[:LIKE]) }
  scope :final_design, ->{ where('final = ? OR mark = ?', true, MARKS[:LIKE]) }
  scope :collaboration, ->{ where(final: false) }
  scope :initial, ->{ none }

  def medium_size_image_url
    image.try(:medium_size_url)
  end

  def image_id
    image.try(:id)
  end

end
