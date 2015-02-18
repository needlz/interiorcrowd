class ProductItem < ActiveRecord::Base

  validates_inclusion_of :mark, in: %w(ok remove), allow_nil: true

  belongs_to :image
  belongs_to :contest_request

end
