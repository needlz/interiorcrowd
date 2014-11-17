class DesignSpace < ActiveRecord::Base
  ACTIVE_STATUS = 1

  has_many :contests
  belongs_to :parent, class_name: 'DesignSpace', foreign_key: :parent_id

  scope :available, where(status: ACTIVE_STATUS).order(pos: :asc)
  scope :top_level, where(parent_id: 0)
  scope :by_ids, ->(ids) { where("id IN (?)", ids).order(:pos) }

  def children
    DesignSpace.where(parent_id: id)
  end

end
