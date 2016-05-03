class DesignerActivityComment < ActiveRecord::Base

  belongs_to :designer_activity
  belongs_to :author, polymorphic: true

  validates_presence_of :text

end
