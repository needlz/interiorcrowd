class FinalNoteToDesigner < ActiveRecord::Base

  normalize_attributes :text
  validates_presence_of :designer_notification_id

  belongs_to :designer_notification, class_name: 'FinalNoteDesignerNotification'

end
