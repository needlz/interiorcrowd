class FinalNotesQuery

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def all
    (contest_request.comments + contest_request.final_notes + contest_request.contest.notes.by_client).sort_by(&:created_at).reverse
  end

  private

  attr_reader :contest_request

end
