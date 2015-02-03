class DesignerInvitedNotification < DesignerNotification

  self.inheritance_column = :type

  belongs_to :designer, foreign_key: :user_id

end
