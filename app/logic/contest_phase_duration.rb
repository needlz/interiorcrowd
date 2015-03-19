class ContestPhaseDuration

  DAYS = {
    'submission' => 7,
    'winner_selection' => 3,
    'fulfillment' => 3
  }

  def initialize(contest)
    @contest = contest
  end

  def phase_end(phase_start_time)
    duration = DAYS[contest.status]
    (phase_start_time + duration.days) if duration
  end

  private

  attr_reader :contest

end
