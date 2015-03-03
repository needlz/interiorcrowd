class ContestNote < ActiveRecord::Base

  belongs_to :contest
  validates_presence_of :text

  def author_name
    contest.client_name
  end

end
