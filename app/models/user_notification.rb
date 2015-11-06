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
#  final_note_id            :integer
#

class UserNotification < ActiveRecord::Base

  belongs_to :contest_comment, class_name: 'ContestNote'
  belongs_to :contest
  belongs_to :concept_board_comment

  self.inheritance_column = :type

  def mark_as_read
    update_attributes!(read: true)
  end

end
