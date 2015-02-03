class DesignerInvitation < DesignerNotification

  validates_uniqueness_of :user_id, scope: :contest_id

  belongs_to :contest
  has_one :client, through: :contest
  belongs_to :designer, foreign_key: :user_id

  def view
    DesignerNotifications::ContestInvitationView.new(self)
  end

end
