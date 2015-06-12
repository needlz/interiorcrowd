# == Schema Information
#
# Table name: lookbook_details
#
#  id          :integer          not null, primary key
#  lookbook_id :integer
#  image_id    :integer
#  description :text
#  url         :text
#  doc_type    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  phase       :string(255)
#

class LookbookDetail < ActiveRecord::Base
  belongs_to :lookbook
  belongs_to :image

  UPLOADED_PICTURE_TYPE = 1
  EXTERNAL_PICTURE_TYPE = 2

  scope :uploaded_pictures, ->{ where(doc_type: UPLOADED_PICTURE_TYPE) }
  scope :external_pictures, ->{ where(doc_type: EXTERNAL_PICTURE_TYPE) }

  def uploaded?
    doc_type == UPLOADED_PICTURE_TYPE
  end

  def external?
    doc_type == EXTERNAL_PICTURE_TYPE
  end
end
