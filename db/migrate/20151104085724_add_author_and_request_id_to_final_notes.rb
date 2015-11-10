class AddAuthorAndRequestIdToFinalNotes < ActiveRecord::Migration
  def change
    add_reference :final_notes, :contest_request
    add_reference :final_notes, :author
    add_column :final_notes, :author_role, :string

    add_reference :user_notifications, :final_note

    FinalNote.all.each do |note|
      designer_notification = FinalNoteDesignerNotification.find_by_id(note.designer_notification_id)
      client = designer_notification.contest_request.contest.client
      note.destroy and next if note.text.blank?
      note.update_attributes!(contest_request_id: designer_notification.contest_request_id,
                              author_id: client.id,
                              author_role: client.role)
      designer_notification.update_attributes!(final_note_id: note.id)
    end

    change_column_null(:final_notes, :contest_request_id, false)
    change_column_null(:final_notes, :author_id, false)
    change_column_null(:final_notes, :author_role, false)
  end
end
