class DesignCategory < ActiveRecord::Base
  
  ACTIVE_STATUS = 1

  has_many :contests

  scope :available, where(status: ACTIVE_STATUS).order(pos: :asc)
  scope :by_ids, ->(ids) { where("id IN (?)", ids).order(:pos) }

  def paid?
    price > 0
  end

end
