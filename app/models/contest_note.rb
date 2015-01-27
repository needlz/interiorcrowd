class ContestNote < ActiveRecord::Base

  belongs_to :contest
  validates_presence_of :text

end
