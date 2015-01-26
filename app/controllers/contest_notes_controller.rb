class ContestNotesController < ApplicationController

  before_filter :set_contest, :check_contest_owner

  def create
    @contest.notes.create!(text: note_params[:text].strip)
    render nothing: true
  end

  private

  def note_params
    params.require(:contest_note).permit(:contest_id, :text)
  end

  def set_contest
    @contest = Contest.find(note_params[:contest_id])
  end

  def check_contest_owner
    return unless check_client
    @client = Client.find(session[:client_id])
    raise_404 unless @contest.client == @client
  end
end
