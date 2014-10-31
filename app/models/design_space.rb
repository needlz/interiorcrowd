class DesignSpace < ActiveRecord::Base
  SPACE_ACTIVE_STATUS = 1
  SPACE_INACTIVE_STATUS = 0

  def children
    DesignSpace.where(parent: id)
  end


end
