class UserNotification < ActiveRecord::Base

  self.inheritance_column = :type

end
