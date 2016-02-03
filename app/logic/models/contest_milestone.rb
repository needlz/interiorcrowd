class ContestMilestone

  DAYS = {
    'submission' => 7,
    'winner_selection' => 7,
    'fulfillment' => 14,
    'final_fulfillment' => 7
  }

  def self.end_milestone_performer(contest_status)
    class_name = "End#{ contest_status.camelize }"
    begin
      class_name.constantize
    rescue NameError
      nil
    end
  end

  def self.finite_milestone?(contest_status)
    DAYS[contest_status]
  end

  def initialize(contest)
    @contest = contest
  end

  def phase_end(phase_start_time)
    duration = DAYS[contest.status]
    (phase_start_time + duration.days).end_of_day if duration
  end

  def end_milestone_performer_class
    ContestMilestone.end_milestone_performer(contest.status)
  end

  def self.show_timeline?(contest_status)
    %w[submission winner_selection].include? contest_status
  end

  private

  attr_reader :contest

end
