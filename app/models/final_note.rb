# == Schema Information
#
# Table name: final_notes
#
#  id                       :integer          not null, primary key
#  text                     :text
#  designer_notification_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  contest_request_id       :integer          not null
#  author_id                :integer          not null
#  author_role              :string           not null
#

class FinalNote < ActiveRecord::Base
  include WithAuthor

  normalize_attributes :text

  has_one :designer_notification, class_name: 'FinalNoteDesignerNotification'
  belongs_to :contest_request

  validates_presence_of :contest_request_id, :author_id, :author_role, :text
  validates_inclusion_of :author_role, in: %w[Designer Client]


  def author_name
    author.name
  end

  def author
    role.constantize.find(author_id)
  end

  def role
    author_role
  end

end
