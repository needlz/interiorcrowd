class ImageItemUpdater

  def initialize(product_item)
    @product_item = product_item
    @contest_request = product_item.contest_request
    @designer = @contest_request.designer
  end

  def perform
    delayed_job = delayed_job_for_email
    delayed_job ? delay_sending_time(delayed_job) : send_email
  end

  private

  def send_email
    Jobs::Mailer.schedule(:product_list_feedback,
                          [{ username: @designer.name, email: @designer.email }, @contest_request.id],
                          { run_at: marks_digest_minutes_interval, contest_request_id: @contest_request.id })
  end

  def delayed_job_for_email
    Delayed::Job.where('handler LIKE ? and contest_request_id = ?', "%product_list_feedback%", @contest_request.id).first
  end

  def delay_sending_time(delayed_job)
    delayed_job.update_attribute(:run_at, marks_digest_minutes_interval)
  end

  def marks_digest_minutes_interval
    Settings.marks_digest_minutes_interval.to_i.minutes.from_now.utc
  end

end