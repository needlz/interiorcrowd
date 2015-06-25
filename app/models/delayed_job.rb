# == Schema Information
#
# Table name: delayed_jobs
#
#  id                 :integer          not null, primary key
#  priority           :integer          default(0), not null
#  attempts           :integer          default(0), not null
#  handler            :text             not null
#  last_error         :text
#  run_at             :datetime
#  locked_at          :datetime
#  failed_at          :datetime
#  locked_by          :string(255)
#  queue              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  contest_id         :integer
#  image_type         :string(255)
#  contest_request_id :integer
#  outbound_email_id  :integer
#

class DelayedJob < ActiveRecord::Base

  belongs_to :contest

  def error(job, exception)
    Rollbar.error(exception, job_id: job.id)
  end

end
