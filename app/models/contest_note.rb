class ContestNote < ActiveRecord::Base

  belongs_to :contest
  belongs_to :designer
  belongs_to :client
  validates_presence_of :text

  def author_name
    contest.client_name
  end

  def author
    client || designer
  end

  def author_role
    author.class.to_s
  end

end
