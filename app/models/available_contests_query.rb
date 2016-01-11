class AvailableContestsQuery

  def initialize(designer)
    @designer = designer
  end

  def all
    Contest.current.all
  end

  def invited
    designer.invited_contests.current.all
  end

  def suggested
    contests = Contest.arel_table
    contest_requests = ContestRequest.arel_table

    requests_submitted_by_designer = contest_requests.project(Arel.sql('id')).
        where(contest_requests[:contest_id].eq(contests[:id]).
            and(contest_requests[:status].not_eq('draft').
            and(contest_requests[:designer_id].eq(designer.id)))
        )

    Contest.current.joins('LEFT JOIN "contest_requests" ON "contest_requests"."contest_id" = "contests"."id"').where.not(requests_submitted_by_designer.exists)
  end

  private

  attr_reader :designer

end
