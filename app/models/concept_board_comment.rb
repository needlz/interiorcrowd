# == Schema Information
#
# Table name: concept_board_comments
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  text               :text
#  contest_request_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  role               :string(255)
#  contest_note_id    :integer
#

class ConceptBoardComment < ActiveRecord::Base
  belongs_to :contest_request
  belongs_to :contest_note

  default_scope { order(created_at: :desc) }

  scope :by_designer, ->{ where(role: 'Designer') }
  scope :by_client, ->{ where(role: 'Client') }

  def income(user)
    send(user.class.name.downcase)
  end

  def author_name
    author.name
  end

  def author
    role.constantize.find(user_id)
  end

  def author_role
    role
  end

  def type
    'ConceptBoardComment'
  end

  def mark_as_read
    update_attributes!(read: true)
  end

end
