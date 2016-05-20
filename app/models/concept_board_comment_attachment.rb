# == Schema Information
#
# Table name: concept_board_comment_attachments
#
#  id            :integer          not null, primary key
#  comment_id    :integer
#  attachment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ConceptBoardCommentAttachment < ActiveRecord::Base
  include Downloadable

  belongs_to :comment, class_name: 'ConceptBoardComment'
  belongs_to :attachment, class_name: 'Image'

  validates_presence_of :comment, :attachment
end
