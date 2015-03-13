class ContestNoteCreation

  def initialize(contest, text, current_user)
    @contest = contest
    @client_id = current_user.id if current_user.client?
    @designer_id = current_user.id if current_user.designer?
    @text = text.strip
  end

  def perform
    contest.notes.create!(text: text, client_id: client_id, designer_id: designer_id)
  end

  private

  attr_reader :client_id, :designer_id, :contest, :text

end
