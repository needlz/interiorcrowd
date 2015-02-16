class ProductItem < ActiveRecord::Base

  belongs_to :image
  belongs_to :contest_request

end
