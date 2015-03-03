class ConceptBoardCommentView < CommentView
  include Rails.application.routes.url_helpers

  def href
    return edit_designer_center_response_path(id: comment.contest_request.id) if spectator.designer?
    contest_request_path(id: comment.contest_request.id) if spectator.client?
  end

end
