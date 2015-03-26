class ImageItem < ActiveRecord::Base

  self.table_name = 'product_items'

  KINDS = %i(product_items similar_styles)
  MARKS = %w(ok remove)

  validates_inclusion_of :mark, in: MARKS, allow_nil: true
  validates_inclusion_of :kind, in: KINDS.map(&:to_s)

  belongs_to :image, dependent: :destroy
  belongs_to :contest_request

  KINDS.each do |kind|
    scope kind, ->{ where(kind: kind.to_s) }
  end

  scope :for_view, ->{ order(:created_at).includes(:image) }

  def medium_size_image_url
    image.try(:medium_size_url)
  end

  def image_id
    image.try(:id)
  end

end
