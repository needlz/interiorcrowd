# == Schema Information
#
# Table name: designer_activity_comments
#
#  id                   :integer          not null, primary key
#  text                 :text
#  designer_activity_id :integer
#  author_id            :integer
#  author_type          :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  read                 :boolean          default(FALSE)
#

class DesignerActivityComment < ActiveRecord::Base

  belongs_to :designer_activity
  belongs_to :author, polymorphic: true

  validates_presence_of :text

end
