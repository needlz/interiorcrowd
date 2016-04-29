class CreateTimeTrackersAttachments < ActiveRecord::Migration
  def change
    create_table :time_trackers_attachments do |t|
      t.references :time_tracker, index: true, foreign_key: true
      t.references :attachment, index: true
    end

    add_foreign_key :time_trackers_attachments, :images, column: :attachment_id
    add_index :time_trackers_attachments,
              [:time_tracker_id, :attachment_id],
              unique: true,
              name: 'time_trackers_on_attachments'
  end
end
