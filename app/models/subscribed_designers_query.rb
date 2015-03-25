class SubscribedDesignersQuery

  def initialize(contest)
    @contest = contest
  end

  def relation
    designers = Designer.arel_table
    contest_requests = ContestRequest.arel_table
    designer_notes = ContestNote.arel_table

    contest_requests_by_designer = contest_requests.project(Arel.sql('id')).
        where(contest_requests[:contest_id].eq(contest.id).
                  and(contest_requests[:designer_id].eq(designers[:id])))

    contest_comments_by_designer = designer_notes.project(Arel.sql('id')).
        where(designer_notes[:designer_id].eq(designers[:id]).
                  and(designer_notes[:contest_id].eq(contest.id)))

    Designer.includes(:contest_requests).
      where(contest_comments_by_designer.exists.or(contest_requests_by_designer.exists))
  end

  private

  attr_reader :contest

end
