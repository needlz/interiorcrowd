class DesignerWinnerNotification < DesignerNotification

  validates_uniqueness_of :user_id, scope: :contest_id

  belongs_to :contest
  has_one :client, through: :contest

end
