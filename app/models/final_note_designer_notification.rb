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

class FinalNoteDesignerNotification < DesignerNotification;

  belongs_to :contest_request
  has_one :final_note_to_designer, foreign_key: :designer_notification_id

end
