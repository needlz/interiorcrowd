class ContestMilestone

  DAYS = {
    'submission' => 7,
    'winner_selection' => 7,
    'fulfillment' => 3
  }

  WORKERS = {
    'submission' => Jobs::SubmissionEnd
  }

  def initialize(contest)
    @contest = contest
  end

  def phase_end(phase_start_time)
    duration = DAYS[contest.status]
    (phase_start_time + duration.days) if duration
  end

  def worker_class
    WORKERS[contest.status]
  end

  private

  attr_reader :contest

end
