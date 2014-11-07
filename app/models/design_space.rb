class DesignSpace < ActiveRecord::Base
  ACTIVE_STATUS = 1

  has_many :contests
  has_one :parent, class_name: 'DesignSpace', foreign_key: :parent

  scope :available, where(status: ACTIVE_STATUS).order(pos: :asc)
  scope :top_level, where(parent: 0)
  scope :by_ids, ->(ids) { where("id IN (?)", ids).order(:pos) }

  def children
    DesignSpace.where(parent: id)
  end

end
