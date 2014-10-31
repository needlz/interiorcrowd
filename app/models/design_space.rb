class DesignSpace < ActiveRecord::Base
  ACTIVE_STATUS = 1

  scope :available, where(status: ACTIVE_STATUS).order(pos: :asc)

  def children
    DesignSpace.where(parent: id)
  end

end
