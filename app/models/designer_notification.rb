# == Schema Information
#
# Table name: user_notifications
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  type                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  contest_id               :integer
#  contest_request_id       :integer
#  read                     :boolean          default(FALSE)
#  contest_comment_id       :integer
#  concept_board_comment_id :integer
#

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
