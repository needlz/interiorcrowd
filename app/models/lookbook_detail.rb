# == Schema Information
#
# Table name: lookbook_details
#
#  id          :integer          not null, primary key
#  lookbook_id :integer
#  image_id    :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  phase       :string(255)
#

class LookbookDetail < ActiveRecord::Base
  belongs_to :lookbook
  belongs_to :image

  validates_presence_of :image_id
end
