class ContestNoteCreation

  def initialize(contest, note_params, current_user)
    @contest = contest
    @client_id = current_user.id if current_user.client?
    @designer_id = current_user.id if current_user.designer?
    @note_params = note_params
  end

  def perform
    contest.notes.create!(text: note_params[:text].strip, client_id: client_id, designer_id: designer_id)
  end

  private

  attr_reader :client_id, :designer_id, :contest, :note_params

end
