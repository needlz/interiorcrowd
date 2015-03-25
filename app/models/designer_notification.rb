class DesignerNotification < UserNotification

  belongs_to :designer, foreign_key: :user_id

  default_scope { where(type: types) }

  def self.types
    %w(DesignerInviteNotification DesignerWinnerNotification DesignerInfoNotification DesignerWelcomeNotification
       ContestCommentDesignerNotification ConceptBoardCommentNotification)
  end

  def recipient
    designer
  end

end
