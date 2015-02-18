class DesignCategory < ActiveRecord::Base
  
  ACTIVE_STATUS = 1

  has_many :contests

  scope :available, ->{ where(status: ACTIVE_STATUS).order(pos: :asc) }

end
