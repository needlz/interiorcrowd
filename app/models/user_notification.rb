class UserNotification < ActiveRecord::Base

  scope :designer_notifications, ->{ where(type: DesignerNotification.types) }

end
