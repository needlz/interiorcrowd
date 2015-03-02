class UpdateMessages

  def initialize(comments)
    @comments = unique(comments)
  end

  def message_name(user, comment)
    comment.role == user.role ? I18n.t('board_comments.me') : user_name(comment.role, comment.user_id)
  end

  private

  def unique(comments)
    comments
    .collect{|comment| {role: comment.role,user_id: comment.user_id, name: comment.user_name}}
    .inject([]){ |result, value| result << value unless result.include?(value); result }
  end

  def user_name(role, id)
    comments
    .select {|comment| comment[:role] == role && comment[:user_id] == id}
    .first[:name]
  end

  attr_reader :comments
end