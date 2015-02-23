class ContestPhaseDuration

  def initialize(contest)
    @contest = contest
  end

  def phase_end(phase_start_time)
    statuses = %w(submission winner_selection fulfillment)
    phase_start_time + 3.days if statuses.include? contest.status 
  end

  private

  attr_reader :contest

end
