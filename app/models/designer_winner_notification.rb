class DesignerWinnerNotification < DesignerNotification

  validates_uniqueness_of :user_id, scope: :contest_id

  belongs_to :contest
  has_one :client, through: :contest
  belongs_to :designer, foreign_key: :user_id


  def self.new_record(user_id, contest_id, request_id)
    create(user_type: superclass.name, user_id: user_id, contest_id: contest_id, contest_request_id: request_id)
  end
end
