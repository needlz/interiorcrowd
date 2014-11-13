class Image < ActiveRecord::Base
  #permit_params :image
  has_attached_file :image, styles: { medium: "200x200>", thumb: "100x100>" }, path: ":class/:id/:style:filename"
  has_one :lookbook_details
end
