class Image < ActiveRecord::Base
  #permit_params :image
  has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "100x100>" }, url: '/images/:id', path: "uploads/:id/:filename"
  has_one :lookbook_details
end
