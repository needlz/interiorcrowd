class ConceptBoardComment < ActiveRecord::Base
  belongs_to :contest_request

  scope :designer, ->{ where(role: 'Designer') }
  scope :client, ->{ where(role: 'Client') }
  scope :unread, ->{ where(read: false) }

  def income( user)
    send(user.class.name.downcase)
  end

end
