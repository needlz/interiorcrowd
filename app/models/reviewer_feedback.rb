# == Schema Information
#
# Table name: reviewer_feedbacks
#
#  id            :integer          not null, primary key
#  text          :text
#  invitation_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class ReviewerFeedback < ActiveRecord::Base

  validates_presence_of :text

  belongs_to :invitation, class_name: 'ReviewerInvitation', foreign_key: 'invitation_id'

end
