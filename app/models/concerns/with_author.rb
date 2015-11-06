module WithAuthor
  extend ActiveSupport::Concern

  def author_name
    author.name
  end

  def author
    author_role.constantize.find(author_id)
  end

end
