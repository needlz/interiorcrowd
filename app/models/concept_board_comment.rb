class ConceptBoardComment < ActiveRecord::Base
  belongs_to :contest_request

  scope :designer, ->{ where(role: 'Designer') }
  scope :client, ->{ where(role: 'Client') }

  def income( user)
    send(user.class.name.downcase)
  end

  def user_name
    role.constantize.find(user_id).name
  end

end
