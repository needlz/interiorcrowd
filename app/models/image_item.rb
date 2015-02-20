class ImageItem < ActiveRecord::Base

  self.table_name = 'product_items'

  KINDS = %i(product_items similar_styles)
  MARKS = %w(ok remove)

  validates_inclusion_of :mark, in: MARKS, allow_nil: true
  validates_inclusion_of :kind, in: KINDS.map(&:to_s)

  KINDS.each do |kind|
    scope kind, ->{ where(kind: kind.to_s) }
  end

  belongs_to :image
  belongs_to :contest_request

end