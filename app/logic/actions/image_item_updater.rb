class ImageItemUpdater

  def initialize(product_item, image_item_attributes, current_user)
    @product_item = product_item
    @contest_request = product_item.contest_request
    @designer = @contest_request.designer
    @image_item_attributes = image_item_attributes
    @current_user = current_user
  end

  def perform
    ActiveRecord::Base.transaction do
      update_params
      if current_user.client?
        delayed_job = delayed_job_for_email
        delayed_job ? delay_sending_time(delayed_job) : send_email
      end
    end
    instant_feedback = InstantFeedBackPublisher.new
    instant_feedback.publish({id: @product_item.temporary_version_id, text: ImageItemView.new(@product_item).mark_text}.to_json)
  end

  private

  attr_reader :image_item_attributes, :contest_request, :product_item, :current_user

  def send_email
    Jobs::Mailer.schedule(:product_list_feedback,
                          [{ username: @designer.name, email: @designer.email }, contest_request.id],
                          { run_at: marks_digest_minutes_interval, contest_request_id: contest_request.id })
  end

  def delayed_job_for_email
    Delayed::Job.where('handler LIKE ? and contest_request_id = ?', "%product_list_feedback%", contest_request.id).first
  end

  def delay_sending_time(delayed_job)
    delayed_job.update_attribute(:run_at, marks_digest_minutes_interval)
  end

  def marks_digest_minutes_interval
    Settings.marks_digest_minutes_interval.to_i.minutes.from_now.utc
  end

  def update_params
    product_item.assign_attributes(image_item_attributes)
    if product_item.image_id_changed? && product_item.published_version
      product_item.published_version = nil
    end
    product_item.save!
  end

end