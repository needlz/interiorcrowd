class ContestNotesController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    @contest.notes.create!(text: note_params[:text].strip)
    last_notes = @contest.notes.order(created_at: :desc)
    note_views = last_notes.map { |note| ContestNoteView.new(note, current_user) }
    render json: note_views.map(&:attributes).to_json
  end

  private

  def note_params
    params.require(:contest_note).permit(:contest_id, :text)
  end

  def set_contest
    @contest = Contest.find(note_params[:contest_id])
  end
end
