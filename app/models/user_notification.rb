class UserNotification < ActiveRecord::Base

  belongs_to :contest_comment, class_name: 'ContestNote'
  belongs_to :contest
  belongs_to :concept_board_comment

  self.inheritance_column = :type

  def mark_as_read
    update_attributes!(read: true)
  end

end
