# == Schema Information
#
# Table name: design_categories
#
#  id         :integer          not null, primary key
#  name       :text
#  pos        :integer
#  price      :integer
#  status     :integer          default(1)
#  created_at :datetime
#  updated_at :datetime
#

class DesignCategory < ActiveRecord::Base
  
  ACTIVE_STATUS = 1

  has_many :contests

  scope :available, ->{ where(status: ACTIVE_STATUS).order(pos: :asc) }

end
