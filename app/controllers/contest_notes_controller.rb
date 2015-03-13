class ContestNotesController < ApplicationController

  before_filter :set_contest

  def create
    return raise_404 if !current_user || !current_user.can_comment_contest?(@contest)
    ContestNoteCreation.new(@contest, note_params[:text], current_user).perform
    last_notes = @contest.notes.order(created_at: :desc).includes(:client, :designer)
    note_views = last_notes.map { |note| ContestNoteView.new(note, current_user) }
    render partial: 'clients/client_center/entries/notes_list', locals: { notes: note_views }
  end

  private

  def note_params
    params.require(:contest_note).permit(:contest_id, :text)
  end

  def set_contest
    @contest = Contest.find(note_params[:contest_id])
  end
end
