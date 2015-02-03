class DesignerInvitedNotification < DesignerNotification

  belongs_to :designer, foreign_key: :user_id

end
