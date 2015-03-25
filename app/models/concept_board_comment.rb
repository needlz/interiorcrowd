class ConceptBoardComment < ActiveRecord::Base
  belongs_to :contest_request

  scope :by_designer, ->{ where(role: 'Designer') }
  scope :by_client, ->{ where(role: 'Client') }

  def income(user)
    send(user.class.name.downcase)
  end

  def author_name
    author.name
  end

  def author_role
    role
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
