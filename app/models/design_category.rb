class DesignCategory < ActiveRecord::Base
  
  CAT_ACTIVE_STATUS = 1
  CAT_INACTIVE_STATUS = 0

  CUSTOM_CATEGORY_ID = 8

  def has_image?
    image_name.present? && image_name != 'null'
  end

end
