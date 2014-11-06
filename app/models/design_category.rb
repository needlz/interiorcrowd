class DesignCategory < ActiveRecord::Base
  
  ACTIVE_STATUS = 1
  CUSTOM_CATEGORY_ID = 8

  scope :available, where(status: ACTIVE_STATUS).order(pos: :asc)
  scope :by_ids, ->(ids) { where("id IN (?)", ids).order(:pos) }

  def has_image?
    image_name.present? && image_name != 'null'
  end

  def custom?
    id == CUSTOM_CATEGORY_ID
  end

  def paid?
    price > 0
  end

end
