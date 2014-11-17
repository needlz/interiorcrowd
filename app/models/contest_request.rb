class ContestRequest < ActiveRecord::Base
  self.per_page = 8

  belongs_to :designer
  belongs_to :contest
  belongs_to :lookbook

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }

  def moodboard_image_path
    lookbook_details = lookbook.lookbook_details
    lookbook_item = lookbook_details.last
    return lookbook_item.image.image.url if lookbook_item.uploaded?
    return lookbook_item.url if lookbook_item.external?
  end
end
