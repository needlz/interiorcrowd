# == Schema Information
#
# Table name: contest_notes
#
#  id          :integer          not null, primary key
#  text        :text
#  contest_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  designer_id :integer
#  client_id   :integer
#

class ContestNote < ActiveRecord::Base

  validates_presence_of :text

  normalize_attributes :text

  belongs_to :contest
  belongs_to :designer
  belongs_to :client
  has_many :contest_comment_designer_notifications, foreign_key: :contest_comment_id
  has_many :concept_board_comments, dependent: :destroy

  scope :by_client, ->{ where.not(client_id: nil) }

  def author_name
    author.name
  end

  def author
    client || designer
  end

  def author_role
    author.class.to_s
  end

  def role
    author_role
  end

  def type
    'ContestComment'
  end

  def contest_owner_name
    contest.client.name
  end

end
