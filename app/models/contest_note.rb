class ContestNote < ActiveRecord::Base

  validates_presence_of :text

  belongs_to :contest
  belongs_to :designer
  belongs_to :client
  has_many :contest_comment_designer_notifications, foreign_key: :contest_comment_id

  scope :by_client, ->{ where.not(client_id: nil) }

  def author_name
    contest.client_name
  end

  def author
    client || designer
  end

  def author_role
    author.class.to_s
  end

  def type
    'ContestComment'
  end

  def contest_owner_name
    contest.client.name
  end

end
