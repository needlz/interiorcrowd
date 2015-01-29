class ReviewerFeedback < ActiveRecord::Base

  validates_presence_of :text

  belongs_to :invitation, class_name: 'ReviewerInvitation', foreign_key: 'invitation_id'

end
