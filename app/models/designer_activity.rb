class DesignerActivity < ActiveRecord::Base

  belongs_to :time_tracker
  has_many :comments, class_name: 'DesignerActivityComment'

  validates_presence_of :hours

end
