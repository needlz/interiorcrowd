class ConceptBoardCommentsController < ApplicationController

  def create
    validate_params_of_create

    comment_creation = ConceptBoardCommentCreation.perform(concept_board, comment_attributes, current_user)

    render json: { comment_html: fetch_comment_html(comment_creation.comment) }
  end

  def update
    validate_params_of_update

    updater = ConceptBoardCommentUpdate.perform(comment, comment_attributes)
    if updater.saved
      comment_html = render_to_string partial: 'designer_center_requests/edit/comment',
                                      locals: { user: current_user,
                                                comment_view: CommentView.create(comment, current_user) }
      render json: { comment_html: comment_html }
    else
      render json: { error: comment.errors.full_messages }
    end
  end

  def destroy
    validate_params_of_update

    if comment.destroy
      render json: { destroyed_comment_id: comment.id }
    else
      render json: { error: comment.errors.full_messages }
    end
  end

  private

  attr_reader :concept_board, :comment

  def comment_attributes
    params.require(:comment).permit([:text, attachments_ids: []])
  end

  def validate_params_of_create
    @concept_board = ContestRequest.find_by_id(params[:contest_request_id])
    if concept_board.blank?
      create_concept_board_by_contest_id
    else
      comment_policy = UserCommentPolicy.for_user(current_user)
      raise_404(comment_policy.error) unless comment_policy.create_comment(concept_board).can?
    end
  end

  def create_concept_board_by_contest_id
    contest = Contest.find(params[:designer_center_contest_id])
    raise_404 unless current_user.designer?
    @concept_board = contest.response_of(current_user)
    @concept_board = ContestRequestCreation.new(designer: current_user,
                                               contest: contest,
                                               request_params: nil,
                                               lookbook_params: nil,
                                               need_submit: false).perform if concept_board.blank?
  end

  def validate_params_of_update
    @concept_board = ContestRequest.find(params[:contest_request_id])
    @comment = @concept_board.comments.find(params[:id])

    UserCommentPolicy.for_user(current_user).
        edit_comment(comment).
        require!
  rescue ActiveRecord::RecordNotFound, PolicyError => e
    raise_404(e)
  end

  def fetch_comment_html(comment)
    render_to_string partial: 'designer_center_requests/edit/comment',
                     locals: { user: current_user,
                               comment_view: CommentView.create(comment, current_user) }
  end

end
