class FinalNotesController < ApplicationController

  def create
    begin
      contest_request = current_user.contest_requests.find(params[:contest_request_id])
    rescue ActiveRecord::RecordNotFound => e
      return raise_404(e)
    end

    begin
      creation = CreateFinalNote.new(contest_request: contest_request,
                                     final_note_attributes: final_note_params,
                                     author: current_user)
    rescue ArgumentError => e
      return raise_404(e)
    end

    creation.perform
    note_views = (contest_request.comments + contest_request.final_notes).sort_by(&:created_at).map do |note|
      ConceptBoardCommentView.new(note, current_user)
    end
    rendered_items = render_to_string(partial: 'designer_center_requests/show/request_comments_read_only',
                                      locals: { comments: note_views })
    render json: { created: true,
                   comments_html: rendered_items,
                   comments_count_text: I18n.t('designer_center.finished.final_note.comments_count',
                                               count: note_views.length) }
  end

  private

  def final_note_params
    params.require(:final_note).permit(:text)
  end

end
