class ConceptBoardCommentAttachment < ActiveRecord::Base
  include Downloadable

  belongs_to :comment, class_name: 'ConceptBoardComment'
  belongs_to :attachment, class_name: 'Image'

  validates_presence_of :comment, :attachment
end
