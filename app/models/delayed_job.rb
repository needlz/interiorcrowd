class DelayedJob < ActiveRecord::Base

  belongs_to :contest

  def error(job, exception)
    Rollbar.error(exception, job_id: job.id)
  end

end
