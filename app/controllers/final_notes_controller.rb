class FinalNotesController < ApplicationController

  def create
    begin
      set_contest_request
      initialize_creator
      @creator.perform
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      return raise_404(e)
    end

    render json: { created: true,
                   comments_html: render_contest_request_comments,
                   comments_count_text: I18n.t('designer_center_requests.show.finished.final_note.comments_count',
                                               count: @note_views.length) }
  end

  private

  def final_note_params
    params.require(:final_note).permit(:text)
  end

  def set_contest_request
    @contest_request = current_user.contest_requests.find(params[:contest_request_id])
  end

  def initialize_creator
    @creator = CreateFinalNote.new(contest_request: @contest_request,
                        final_note_attributes: final_note_params,
                        author: current_user)
  end

  def render_contest_request_comments
    @note_views = (@contest_request.comments + @contest_request.final_notes).sort_by(&:created_at).map do |note|
      ConceptBoardCommentView.new(note, current_user)
    end
    render_to_string(partial: 'shared/request_comments_read_only',
                     locals: { comments: @note_views })
  end

end
