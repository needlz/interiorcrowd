class ContestPhaseDuration

  def initialize(contest)
    @contest = contest
  end

  def phase_end(phase_start_time)
    return phase_start_time + 3.days if contest.status == 'submission'
    return phase_start_time + 3.days if contest.status == 'winner_selection'
    return phase_start_time + 3.days if contest.status == 'fulfillment'
  end

  private

  attr_reader :contest

end
