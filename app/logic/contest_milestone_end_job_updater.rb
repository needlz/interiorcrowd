class ContestMilestoneEndJobUpdater

  def initialize(contest)
    @contest = contest
  end

  def perform
    clear_phase_end_jobs
    create_phase_job if (contest.phase_end && contest.phase_end > Time.current)
  end

  private

  attr_reader :contest

  def create_phase_job
    performer_class = ContestMilestone.new(contest).end_milestone_performer_class
    Jobs::ContestMilestoneEnd.schedule(contest.id, contest.status, run_at: contest.phase_end) if performer_class
  end

  def clear_phase_end_jobs
    phase_job_classes = "(handler LIKE '%#{ Jobs::ContestMilestoneEnd.name }%')"
    Delayed::Job.where(contest_id: contest.id).where(phase_job_classes).destroy_all
  end

end
