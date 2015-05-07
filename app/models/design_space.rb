# == Schema Information
#
# Table name: design_spaces
#
#  id         :integer          not null, primary key
#  name       :text
#  pos        :integer
#  parent_id  :integer
#  status     :integer          default(1)
#  created_at :datetime
#  updated_at :datetime
#

class DesignSpace < ActiveRecord::Base
  ACTIVE_STATUS = 1

  has_many :contests
  belongs_to :parent, class_name: 'DesignSpace', foreign_key: :parent_id
  has_many :children, class_name: 'DesignSpace', foreign_key: :parent_id

  scope :available, ->{ where(status: ACTIVE_STATUS).order(pos: :asc) }
  scope :top_level, ->{ where(parent_id: 0) }

end
