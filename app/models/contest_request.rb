class ContestRequest < ActiveRecord::Base
  belongs_to :designer
  belongs_to :contest
  belongs_to :lookbook

  def moodboard_image_path
    lookbook_details = lookbook.lookbook_details
    lookbook_item = lookbook_details.last
    return lookbook_item.image.image.url if lookbook_item.uploaded?
    return lookbook_item.url if lookbook_item.external?
  end
end
