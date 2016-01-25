class UserCommentPolicy < Policy

  def self.for_user(user)
    new(user)
  end

  def initialize(user)
    super
    @user = user
  end

  def create_comment(concept_board)
    permissions << user.can_comment_contest_request?(concept_board)
    self
  end

  def edit_comment(comment)
    permissions << (comment.author == user)
    self
  end

  private

  attr_reader :user

end
