class DesignerNotification < UserNotification

  belongs_to :designer, foreign_key: :user_id

  default_scope { where(type: types) }

  def self.types
    %w(DesignerInvitation)
  end

  def contest_request
    ContestRequest.where(contest_id: contest.id, designer_id: user_id).last.id
  end

end
