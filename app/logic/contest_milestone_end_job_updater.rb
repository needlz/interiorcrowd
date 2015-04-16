class ContestMilestoneEndJobUpdater

  def initialize(contest)
    @contest = contest
  end

  def perform
    if contest.phase_end_changed? || contest.status_changed?
      clear_phase_end_jobs
      create_phase_job if (contest.phase_end > Time.current)
    end
  end

  private

  attr_reader :contest

  def create_phase_job
    worker_class = ContestMilestone.new(contest).worker_class
    worker_class.schedule(contest.id, run_at: contest.phase_end) if worker_class
  end

  def clear_phase_end_jobs
    phase_job_classes = ContestMilestone::WORKERS.values.map{ |job| "(handler LIKE '%#{ job.name }%')" }.join(' OR ')
    Delayed::Job.where(contest_id: contest.id).where(phase_job_classes).destroy_all
  end

end
