# == Schema Information
#
# Table name: final_note_to_designers
#
#  id                       :integer          not null, primary key
#  text                     :text
#  designer_notification_id :integer
#

class FinalNoteToDesigner < ActiveRecord::Base

  normalize_attributes :text
  validates_presence_of :designer_notification_id

  belongs_to :designer_notification, class_name: 'FinalNoteDesignerNotification'

end
