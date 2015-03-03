class ConceptBoardCommentView < CommentView
  include Rails.application.routes.url_helpers

  def href
    if spectator.kind_of?(Designer)
      edit_designer_center_response_path(id: comment.contest_request.id)
    elsif spectator.kind_of?(Client)
      contest_request_path(id: comment.contest_request.id)
    end
  end

end
